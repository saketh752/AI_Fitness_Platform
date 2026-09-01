import json
from typing import Any

from pydantic import ValidationError

from app.tools.registry import ToolRegistry


class ToolExecutionError(Exception):
    """Raised when a tool cannot be safely executed."""


class ToolExecutor:
    """Validates and executes allowlisted tool requests."""

    def __init__(self, registry: ToolRegistry) -> None:
        self.registry = registry

    def validate(
        self,
        tool_name: str,
        raw_arguments: str,
    ) -> tuple[Any, dict[str, Any]]:

        tool = self.registry.get(tool_name)

        if tool is None:
            raise ToolExecutionError(
                f"Tool '{tool_name}' is not allowed."
            )

        try:
            arguments = json.loads(raw_arguments)
        except json.JSONDecodeError as exc:
            raise ToolExecutionError(
                "Tool arguments are not valid JSON."
            ) from exc

        try:
            validated_arguments = tool.input_model.model_validate(
                arguments
            )
        except ValidationError as exc:
            raise ToolExecutionError(
                "Tool arguments failed validation."
            ) from exc

        return tool, validated_arguments.model_dump()

    def execute(
        self,
        tool_name: str,
        raw_arguments: str,
        confirmed: bool = False,
    ) -> dict[str, Any]:

        tool, arguments = self.validate(
            tool_name,
            raw_arguments,
        )

        if tool.permission == "write" and not confirmed:
            return {
        "status": "confirmation_required",
        "tool": tool.name,
        "arguments": arguments,
        "message": (
            "This action would modify user data "
            "and requires explicit user confirmation."
        ),
    }

        try:
            result = tool.handler(**arguments)
        except Exception as exc:
            raise ToolExecutionError(
                "Tool execution failed."
            ) from exc

        return result