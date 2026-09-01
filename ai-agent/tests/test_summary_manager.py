from app.agent.summary_manager import SummaryManager
from app.schemas.conversation import ConversationMessage


def test_summary_is_created_from_conversation():
    messages = [
        ConversationMessage(
            role="user",
            content="I only have 20 minutes today.",
        ),
        ConversationMessage(
            role="assistant",
            content="We can shorten your workout.",
        ),
        ConversationMessage(
            role="user",
            content="I prefer dumbbells.",
        ),
    ]

    summary = SummaryManager.build_summary(messages)

    assert summary is not None
    assert "20 minutes" in summary
    assert "dumbbells" in summary


def test_summary_is_none_for_empty_conversation():
    summary = SummaryManager.build_summary([])

    assert summary is None


def test_summary_ignores_tool_messages():
    messages = [
        ConversationMessage(
            role="user",
            content="Show my workout.",
        ),
        ConversationMessage(
            role="tool",
            content="Internal workout data.",
        ),
        ConversationMessage(
            role="assistant",
            content="Here is your workout.",
        ),
    ]

    summary = SummaryManager.build_summary(messages)

    assert "Internal workout data." not in summary
    assert "Show my workout." in summary


def test_summary_limits_recent_user_messages():
    messages = [
        ConversationMessage(
            role="user",
            content=f"User message {index}",
        )
        for index in range(10)
    ]

    summary = SummaryManager.build_summary(messages)

    assert "User message 9" in summary
    assert "User message 8" in summary