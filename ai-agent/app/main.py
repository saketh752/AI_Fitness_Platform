from fastapi import FastAPI

from app.api.routes import router
from app.config.settings import settings


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
)

app.include_router(router)


@app.get("/")
def root():
    return {
        "service": settings.app_name,
        "version": settings.app_version,
        "environment": settings.environment,
        "status": "running",
        "docs_url": "/docs",
        "chat_endpoint": "/api/v1/agent/chat",
        "method": "POST"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": settings.app_version,
    }


@app.get("/api/v1/agent/chat")
@app.get("/api/v1/chat")
@app.get("/chat")
def chat_info():
    return {
        "message": "AI Agent Chat endpoint expects a POST request with JSON body (user_id, message, conversation_id).",
        "interactive_docs": "/docs",
        "example_payload": {
            "user_id": "user_123",
            "message": "Hello Coach! How can I build upper body strength?",
            "conversation_id": "conv_001"
        }
    }