class AgentError(Exception):
    """Base exception for AI agent failures."""


class LLMServiceError(AgentError):
    """Raised when the LLM service fails."""


class AgentTimeoutError(AgentError):
    """Raised when an agent operation exceeds its limit."""