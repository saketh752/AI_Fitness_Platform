from typing import Any

from app.agent.action_builder import ActionBuilder
from app.agent.context_manager import ContextManager
from app.agent.conversation_store import (
    ConversationOwnershipError,
    ConversationStore,
)
from app.agent.errors import LLMServiceError
from app.agent.result import AgentAction, AgentResult
from app.agent.summary_manager import SummaryManager
from app.config.settings import settings
from app.llm.groq_client import GroqClient
from app.llm.prompts import SYSTEM_PROMPT
from app.safety.guardrails import check_action_claim, check_output, check_scope
from app.schemas.context import FitnessContext
from app.schemas.conversation import ConversationMessage
from app.tools.default_registry import create_default_registry
from app.tools.executor import ToolExecutionError, ToolExecutor
from app.tools.groq_tools import build_groq_tools


class FitnessAgent:
    """
    Coordinates safety, context, conversation history,
    summaries, LLM interaction, and controlled tools.
    """

    def __init__(self) -> None:
        # LLM client
        self.groq = GroqClient()

        # Fitness context
        self.context_manager = ContextManager()

        # Controlled tool system
        self.tool_registry = create_default_registry()
        self.tool_executor = ToolExecutor(self.tool_registry)
        self.groq_tools = build_groq_tools(self.tool_registry)

        # Temporary in-memory conversation storage
        self.conversation_store = ConversationStore()

        # Conversation summary manager
        self.summary_manager = SummaryManager()

    def chat(
        self,
        user_id: str,
        conversation_id: str,
        message: str,
        context: FitnessContext | None = None,
    ) -> AgentResult:

        # ---------------------------------------------------------
        # 1. INPUT SAFETY CHECK
        # ---------------------------------------------------------
        scope_result = check_scope(message)

        if not scope_result.allowed:
            return self._scope_refusal()

        # ---------------------------------------------------------
        # 2. GET CONVERSATION HISTORY + VERIFY OWNERSHIP
        # ---------------------------------------------------------
        try:
            conversation_messages = (
                self.conversation_store.get_messages(
                    conversation_id=conversation_id,
                    user_id=user_id,
                    limit=settings.conversation_history_limit,
                )
            )

            conversation_summary = (
                self.conversation_store.get_summary(
                    conversation_id=conversation_id,
                    user_id=user_id,
                )
            )

        except ConversationOwnershipError:
            return AgentResult(
                message="I couldn't access that conversation."
            )

        # ---------------------------------------------------------
        # 3. BUILD FITNESS CONTEXT
        # ---------------------------------------------------------
        fitness_context = self.context_manager.build_context(
            context
        )

        # ---------------------------------------------------------
        # 4. BUILD MODEL MESSAGE HISTORY
        # ---------------------------------------------------------
        messages: list[dict[str, Any]] = [
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            {
                "role": "system",
                "content": fitness_context,
            },
        ]

        # Add older conversation summary if available
        if conversation_summary:
            messages.append(
                {
                    "role": "system",
                    "content": (
                        "The following is a summary of older "
                        "conversation history. Treat it as "
                        "conversational memory, not authoritative "
                        "fitness state:\n\n"
                        + conversation_summary
                    ),
                }
            )

        # Add recent conversation messages
        for previous_message in conversation_messages:
            messages.append(
                {
                    "role": previous_message.role,
                    "content": previous_message.content,
                }
            )

        # Add current user message
        messages.append(
            {
                "role": "user",
                "content": message,
            }
        )

        # ---------------------------------------------------------
        # 5. STORE CURRENT USER MESSAGE
        # ---------------------------------------------------------
        try:
            self.conversation_store.add_message(
                conversation_id=conversation_id,
                user_id=user_id,
                message=ConversationMessage(
                    role="user",
                    content=message,
                ),
            )

        except ConversationOwnershipError:
            return AgentResult(
                message="I couldn't access that conversation."
            )

        # ---------------------------------------------------------
        # 6. INITIAL GROQ REQUEST
        # ---------------------------------------------------------
        try:
            response = self.groq.chat(
                messages,
                tools=self.groq_tools,
            )

        except LLMServiceError:
            return AgentResult(
                message=(
                    "I'm having trouble connecting to the AI service "
                    "right now. Your fitness data has not been changed."
                )
            )

        assistant_message = response.choices[0].message

        actions: list[AgentAction] = []

        # ---------------------------------------------------------
        # 7. HANDLE TOOL CALLS
        # ---------------------------------------------------------
        if assistant_message.tool_calls:

            # Add assistant tool-call message to temporary
            # model conversation.
            messages.append(
                {
                    "role": "assistant",
                    "content": assistant_message.content or "",
                    "tool_calls": [
                        {
                            "id": tool_call.id,
                            "type": "function",
                            "function": {
                                "name": tool_call.function.name,
                                "arguments": (
                                    tool_call.function.arguments
                                ),
                            },
                        }
                        for tool_call in assistant_message.tool_calls
                    ],
                }
            )

            tool_iterations = 0

            for tool_call in assistant_message.tool_calls:

                tool_iterations += 1

                if (
                    tool_iterations
                    > settings.max_tool_iterations
                ):
                    return AgentResult(
                        message=(
                            "I couldn't safely complete that request "
                            "because the action sequence exceeded "
                            "its safety limit."
                        )
                    )

                try:
                    # -------------------------------------------------
                    # 7A. CHECK TOOL EXISTS
                    # -------------------------------------------------
                    tool = self.tool_registry.get(
                        tool_call.function.name
                    )

                    if tool is None:
                        return self._tool_error()

                    # -------------------------------------------------
                    # 7B. VALIDATE TOOL ARGUMENTS
                    # -------------------------------------------------
                    _, arguments = self.tool_executor.validate(
                        tool_call.function.name,
                        tool_call.function.arguments,
                    )

                    # -------------------------------------------------
                    # 7C. HANDLE WRITE TOOLS
                    # -------------------------------------------------
                    if tool.permission == "write":

                        action = (
                            ActionBuilder.confirmation_action(
                                tool_call.function.name,
                                arguments,
                            )
                        )

                        actions.append(action)

                        tool_result = {
                            "status": "confirmation_required",
                            "message": (
                                "The requested action requires "
                                "explicit user confirmation."
                            ),
                        }

                    # -------------------------------------------------
                    # 7D. HANDLE READ TOOLS
                    # -------------------------------------------------
                    else:

                        tool_result = (
                            self.tool_executor.execute(
                                tool_call.function.name,
                                tool_call.function.arguments,
                            )
                        )

                except ToolExecutionError:
                    return self._tool_error()

                # -----------------------------------------------------
                # 7E. SEND TOOL RESULT BACK TO GROQ
                # -----------------------------------------------------
                messages.append(
                    {
                        "role": "tool",
                        "tool_call_id": tool_call.id,
                        "content": str(tool_result),
                    }
                )

            # ---------------------------------------------------------
            # 8. FINAL GROQ RESPONSE
            # ---------------------------------------------------------
            try:
                final_response = self.groq.chat(
                    messages,
                    tools=self.groq_tools,
                )

            except LLMServiceError:
                return AgentResult(
                    message=(
                        "I'm having trouble connecting to the AI "
                        "service right now. Your fitness data has "
                        "not been changed."
                    ),
                    actions=actions,
                    requires_confirmation=bool(actions),
                )

            final_message = final_response.choices[0].message
            final_text = final_message.content or ""

        else:
            # No tool call. Use initial assistant response.
            final_text = assistant_message.content or ""

        # ---------------------------------------------------------
        # 9. OUTPUT SAFETY CHECK
        # ---------------------------------------------------------
        output_result = check_output(final_text)

        if not output_result.allowed:
            return self._scope_refusal()

        # Prevent unsupported claims that a pending write action
        # has already been completed.
        action_claim_result = check_action_claim(
            final_text,
            has_pending_actions=bool(actions),
        )

        if not action_claim_result.allowed:
            final_text = (
                "I can make that change, but I need your "
                "confirmation before anything is updated."
            )

        # ---------------------------------------------------------
        # 10. STORE ASSISTANT RESPONSE
        # ---------------------------------------------------------
        try:
            self.conversation_store.add_message(
                conversation_id=conversation_id,
                user_id=user_id,
                message=ConversationMessage(
                    role="assistant",
                    content=final_text,
                ),
            )

        except ConversationOwnershipError:
            return AgentResult(
                message="I couldn't access that conversation."
            )

        # ---------------------------------------------------------
        # 11. UPDATE CONVERSATION SUMMARY
        # ---------------------------------------------------------
        try:
            all_messages = self.conversation_store.get_messages(
                conversation_id=conversation_id,
                user_id=user_id,
            )

            summary = self.summary_manager.build_summary(
                all_messages
            )

            self.conversation_store.set_summary(
                conversation_id=conversation_id,
                user_id=user_id,
                summary=summary,
            )

        except ConversationOwnershipError:
            return AgentResult(
                message="I couldn't access that conversation."
            )

        # ---------------------------------------------------------
        # 12. RETURN STRUCTURED RESULT
        # ---------------------------------------------------------
        return AgentResult(
            message=final_text,
            actions=actions,
            suggestions=[],
            requires_confirmation=bool(actions),
        )

    @staticmethod
    def _scope_refusal() -> AgentResult:
        return AgentResult(
            message=(
                "I'm your AI fitness coach, so I can help with "
                "workouts, nutrition, fitness goals, recovery, "
                "and progress. I can't help with unrelated requests."
            )
        )

    @staticmethod
    def _tool_error() -> AgentResult:
        return AgentResult(
            message=(
                "I couldn't safely complete that fitness action. "
                "Please try asking in a different way."
            )
        )