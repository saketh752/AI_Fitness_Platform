from types import SimpleNamespace

import pytest

from app.agent.conversation_store import (
    ConversationOwnershipError,
    ConversationStore,
)
from app.agent.orchestrator import FitnessAgent
from app.schemas.conversation import ConversationMessage


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


def test_agent_stores_user_and_assistant_messages(monkeypatch):
    agent = FitnessAgent()

    responses = iter(
        [
            make_response(
                "Let's keep today's workout within 20 minutes."
            ),
        ]
    )

    def fake_chat(messages, tools=None):
        return next(responses)

    monkeypatch.setattr(
        agent.groq,
        "chat",
        fake_chat,
    )

    result = agent.chat(
        user_id="user-001",
        conversation_id="conversation-001",
        message="I only have 20 minutes today.",
    )

    assert result.message == (
        "Let's keep today's workout within 20 minutes."
    )

    messages = agent.conversation_store.get_messages(
        "conversation-001",
        "user-001",
    )

    assert len(messages) == 2
    assert messages[0].role == "user"
    assert messages[1].role == "assistant"


def test_agent_sends_previous_conversation_to_groq(monkeypatch):
    agent = FitnessAgent()

    captured_messages = []

    responses = iter(
        [
            make_response("First response."),
            make_response("Second response."),
        ]
    )

    def fake_chat(messages, tools=None):
        captured_messages.append(messages)
        return next(responses)

    monkeypatch.setattr(
        agent.groq,
        "chat",
        fake_chat,
    )

    agent.chat(
        user_id="user-001",
        conversation_id="conversation-001",
        message="I only have 20 minutes today.",
    )

    agent.chat(
        user_id="user-001",
        conversation_id="conversation-001",
        message="Make it focused on chest.",
    )

    second_request = captured_messages[1]

    contents = [
        message["content"]
        for message in second_request
    ]

    assert "I only have 20 minutes today." in contents
    assert "First response." in contents
    assert "Make it focused on chest." in contents


def test_agent_rejects_wrong_conversation_owner():
    agent = FitnessAgent()

    agent.conversation_store.add_message(
        conversation_id="conversation-001",
        user_id="user-001",
        message=ConversationMessage(
            role="user",
            content="Private conversation.",
        ),
    )

    result = agent.chat(
        user_id="user-002",
        conversation_id="conversation-001",
        message="Show me the previous conversation.",
    )

    assert result.message == (
        "I couldn't access that conversation."
    )