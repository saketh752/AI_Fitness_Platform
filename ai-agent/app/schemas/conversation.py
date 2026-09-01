from typing import Literal

from pydantic import BaseModel, Field


MessageRole = Literal["user", "assistant", "tool"]


class ConversationMessage(BaseModel):
    role: MessageRole
    content: str
    tool_call_id: str | None = None


class Conversation(BaseModel):
    conversation_id: str
    user_id: str
    summary: str | None = None
    messages: list[ConversationMessage] = Field(
        default_factory=list
    )