from typing import Any

from pydantic import BaseModel, Field


class AgentAction(BaseModel):
    type: str
    status: str
    target_id: str | None = None
    arguments: dict[str, Any] = Field(
        default_factory=dict
    )


class AgentChatResponse(BaseModel):
    conversation_id: str
    message: str
    actions: list[AgentAction] = Field(
        default_factory=list
    )
    suggestions: list[str] = Field(
        default_factory=list
    )
    requires_confirmation: bool = False