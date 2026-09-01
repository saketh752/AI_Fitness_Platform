from dataclasses import dataclass, field
from typing import Any


@dataclass
class AgentAction:
    """Represents a structured action proposed by the AI agent."""

    type: str
    status: str
    target_id: str | None = None
    arguments: dict[str, Any] = field(default_factory=dict)


@dataclass
class AgentResult:
    """Complete result returned internally by the AI agent."""

    message: str
    actions: list[AgentAction] = field(default_factory=list)
    suggestions: list[str] = field(default_factory=list)
    requires_confirmation: bool = False