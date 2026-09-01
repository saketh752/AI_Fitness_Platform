import pytest

from app.agent.conversation_store import (
    ConversationOwnershipError,
    ConversationStore,
)
from app.schemas.conversation import ConversationMessage
def test_other_user_cannot_access_conversation():
    store = ConversationStore()

    store.add_message(
        "conversation-001",
        "user-001",
        ConversationMessage(
            role="user",
            content="My workout question.",
        ),
    )

    with pytest.raises(ConversationOwnershipError):
        store.get_messages(
            "conversation-001",
            "user-002",
        )


def test_conversation_is_created():
    store = ConversationStore()

    conversation = store.get_or_create(
        "conversation-001",
        "user-001",
    )

    assert conversation.conversation_id == "conversation-001"
    assert conversation.user_id == "user-001"
    assert conversation.messages == []


def test_messages_are_persisted():
    store = ConversationStore()

    store.add_message(
        "conversation-001",
        "user-001",
        ConversationMessage(
            role="user",
            content="I only have 20 minutes today.",
        ),
    )

    messages = store.get_messages(
        "conversation-001",
        "user-001",
    )

    assert len(messages) == 1
    assert messages[0].content == (
        "I only have 20 minutes today."
    )


def test_conversation_preserves_message_order():
    store = ConversationStore()

    store.add_message(
        "conversation-001",
        "user-001",
        ConversationMessage(
            role="user",
            content="I only have 20 minutes today.",
        ),
    )

    store.add_message(
        "conversation-001",
        "user-001",
        ConversationMessage(
            role="assistant",
            content="I'll help shorten your workout.",
        ),
    )

    messages = store.get_messages(
        "conversation-001",
        "user-001",
    )

    assert messages[0].role == "user"
    assert messages[1].role == "assistant"


def test_conversation_can_be_cleared():
    store = ConversationStore()

    store.add_message(
        "conversation-001",
        "user-001",
        ConversationMessage(
            role="user",
            content="Hello.",
        ),
    )

    store.clear(
    "conversation-001",
    "user-001",
)

    messages = store.get_messages(
        "conversation-001",
        "user-001",
    )

    assert messages == []
def test_conversation_history_limit_returns_most_recent_messages():
    store = ConversationStore()

    for index in range(5):
        store.add_message(
            "conversation-001",
            "user-001",
            ConversationMessage(
                role="user",
                content=f"Message {index}",
            ),
        )

    messages = store.get_messages(
        "conversation-001",
        "user-001",
        limit=2,
    )

    assert len(messages) == 2
    assert messages[0].content == "Message 3"
    assert messages[1].content == "Message 4"

def test_conversation_summary_can_be_stored_and_retrieved():
    store = ConversationStore()

    store.set_summary(
        "conversation-001",
        "user-001",
        "User prefers short workouts and dumbbells.",
    )

    summary = store.get_summary(
        "conversation-001",
        "user-001",
    )

    assert summary == (
        "User prefers short workouts and dumbbells."
    )