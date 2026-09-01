from app.schemas.conversation import ConversationMessage


class SummaryManager:
    """
    Manages conversation summaries.

    The initial implementation is deterministic and does not call
    the LLM. It prepares a compact textual representation that can
    later be replaced with LLM-generated summarization.
    """

    @staticmethod
    def build_summary(
        messages: list[ConversationMessage],
    ) -> str | None:

        if not messages:
            return None

        user_messages = [
            message.content
            for message in messages
            if message.role == "user"
        ]

        assistant_messages = [
            message.content
            for message in messages
            if message.role == "assistant"
        ]

        summary_parts: list[str] = []

        if user_messages:
            summary_parts.append(
                "Recent user topics: "
                + " | ".join(user_messages[-5:])
            )

        if assistant_messages:
            summary_parts.append(
                "Recent assistant responses: "
                + " | ".join(assistant_messages[-3:])
            )

        return "\n".join(summary_parts)