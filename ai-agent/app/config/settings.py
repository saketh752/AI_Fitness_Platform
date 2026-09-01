from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "AI Fitness Agent"
    app_version: str = "0.3.0"
    environment: str = "development"

    groq_api_key: str = ""
    groq_model: str = ""

    conversation_history_limit: int = 10
    max_completion_tokens: int = 1200
    max_tool_iterations: int = 3

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


settings = Settings()