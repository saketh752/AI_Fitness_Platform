from fastapi import APIRouter

from app.agent.orchestrator import FitnessAgent
from app.schemas.requests import AgentChatRequest
from app.schemas.responses import AgentChatResponse


router = APIRouter(
    prefix="/api/v1/agent",
    tags=["AI Agent"],
)

agent = FitnessAgent()


@router.post(
    "/chat",
    response_model=AgentChatResponse,
)
def chat(request: AgentChatRequest) -> AgentChatResponse:
    result = agent.chat(
        user_id=request.user_id,
        conversation_id=request.conversation_id,
        message=request.message,
        context=request.context,
    )

    return AgentChatResponse(
        conversation_id=request.conversation_id,
        message=result.message,
        actions=[
            {
                "type": action.type,
                "status": action.status,
                "target_id": action.target_id,
                "arguments": action.arguments,
            }
            for action in result.actions
        ],
        suggestions=result.suggestions,
        requires_confirmation=result.requires_confirmation,
    )