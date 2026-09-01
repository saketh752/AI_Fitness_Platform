from types import SimpleNamespace

from app.agent.orchestrator import FitnessAgent


def make_response(content: str):
    return SimpleNamespace(
        choices=[
            SimpleNamespace(
                message=SimpleNamespace(
                    content=content,
                    tool_calls=None,
                )
            )
        ]
    )


def test_agent_creates_conversation_summary(monkeypatch):
    agent = FitnessAgent()

    responses = iter(
        [
            make_response(
                "We can keep your workout within 20 minutes."
            ),
        ]
    )

    monkeypatch.setattr(
        agent.groq,
        "chat",
        lambda messages, tools=None: next(responses),
    )

    agent.chat(
        user_id="user-001",
        conversation_id="summary-001",
        message="I only have 20 minutes today.",
    )

    summary = agent.conversation_store.get_summary(
        "summary-001",
        "user-001",
    )

    assert summary is not None
    assert "20 minutes" in summary