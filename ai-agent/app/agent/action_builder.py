from typing import Any

from app.agent.result import AgentAction


class ActionBuilder:
    """Creates structured action proposals from validated tool requests."""

    @staticmethod
    def confirmation_action(
        tool_name: str,
        arguments: dict[str, Any],
    ) -> AgentAction:

        target_id = (
            arguments.get("workout_id")
            or arguments.get("meal_plan_id")
        )

        return AgentAction(
            type=tool_name,
            status="pending_confirmation",
            target_id=target_id,
            arguments=arguments,
        )