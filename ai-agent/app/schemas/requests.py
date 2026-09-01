from pydantic import BaseModel, Field

from app.schemas.context import FitnessContext


class AgentChatRequest(BaseModel):
    user_id: str = Field(default="default_user", min_length=1)
    conversation_id: str = Field(default="default_conv", min_length=1)
    message: str = Field(
        min_length=1,
        max_length=4000,
    )
    context: FitnessContext | None = None