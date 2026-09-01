from typing import Any

from groq import Groq

from app.agent.errors import LLMServiceError
from app.config.settings import settings


class GroqClient:
    """Wrapper around the Groq SDK."""

    def __init__(self) -> None:
        if not settings.groq_api_key:
            raise RuntimeError("GROQ_API_KEY is not configured.")

        if not settings.groq_model:
            raise RuntimeError("GROQ_MODEL is not configured.")

        self.client = Groq(api_key=settings.groq_api_key)
        self.model = settings.groq_model

    def chat(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]] | None = None,
    ):
        request: dict[str, Any] = {
            "model": self.model,
            "messages": messages,
            "max_completion_tokens": settings.max_completion_tokens,
        }

        if tools:
            request["tools"] = tools
            request["tool_choice"] = "auto"

        try:
            return self.client.chat.completions.create(**request)

        except Exception as exc:
            raise LLMServiceError(
                "The LLM service is currently unavailable."
            ) from exc