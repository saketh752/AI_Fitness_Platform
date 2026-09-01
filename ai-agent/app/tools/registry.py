from dataclasses import dataclass
from typing import Callable, Literal


ToolPermission = Literal["read", "write"]


@dataclass(frozen=True)
class ToolDefinition:
    name: str
    description: str
    input_model: type
    handler: Callable
    permission: ToolPermission


class ToolRegistry:
    """Allowlisted collection of tools available to the agent."""

    def __init__(self) -> None:
        self._tools: dict[str, ToolDefinition] = {}

    def register(self, tool: ToolDefinition) -> None:
        self._tools[tool.name] = tool

    def get(self, name: str) -> ToolDefinition | None:
        return self._tools.get(name)

    def names(self) -> list[str]:
        return list(self._tools.keys())