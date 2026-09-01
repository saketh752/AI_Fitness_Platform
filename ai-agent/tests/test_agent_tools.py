from types import SimpleNamespace

from app.agent.orchestrator import FitnessAgent


def make_tool_call(
    tool_id: str,
    tool_name: str,
    arguments: str,
):
    return SimpleNamespace(
        id=tool_id,
        type="function",
        function=SimpleNamespace(
            name=tool_name,
            arguments=arguments,
        ),
    )


def make_response(
    content: str | None = None,
    tool_calls=None,
):
    message = SimpleNamespace(
        content=content,
        tool_calls=tool_calls,
    )

    return SimpleNamespace(
        choices=[
            SimpleNamespace(
                message=message,
            )
        ]
    )


def test_agent_rejects_unregistered_tool(monkeypatch):
    agent = FitnessAgent()

    malicious_tool_response = make_response(
        tool_calls=[
            make_tool_call(
                tool_id="call-malicious",
                tool_name="execute_python",
                arguments='{"code": "print(123)"}',
            )
        ]
    )

    monkeypatch.setattr(
        agent.groq,
        "chat",
        lambda messages, tools=None: malicious_tool_response,
    )

    response = agent.chat(
        user_id="test-user-001",
        conversation_id="tool-test-001",
        message="Do something for me.",
    )

    assert "couldn't safely complete" in response.message.lower()


def test_agent_executes_requested_workout_tool(monkeypatch):
    agent = FitnessAgent()

    first_response = make_response(
        tool_calls=[
            make_tool_call(
                tool_id="call-001",
                tool_name="get_workout",
                arguments='{"workout_id": "workout-001"}',
            )
        ]
    )

    second_response = make_response(
        content=(
            "Your current workout is available and "
            "was retrieved successfully."
        )
    )

    responses = iter(
        [
            first_response,
            second_response,
        ]
    )

    def fake_chat(messages, tools=None):
        return next(responses)

    monkeypatch.setattr(
        agent.groq,
        "chat",
        fake_chat,
    )

    response = agent.chat(
        user_id="test-user-001",
        conversation_id="tool-test-002",
        message="What is the status of my current workout?",
    )

    assert response.message == (
        "Your current workout is available and "
        "was retrieved successfully."
    )


def test_agent_proposes_workout_modification_without_executing(
    monkeypatch,
):
    agent = FitnessAgent()

    first_response = make_response(
        tool_calls=[
            make_tool_call(
                tool_id="call-write-001",
                tool_name="modify_workout",
                arguments=(
                    '{"workout_id":"workout-001",'
                    '"change_type":"reduce_duration",'
                    '"value":20,'
                    '"reason":"User only has 20 minutes today."}'
                ),
            )
        ]
    )

    second_response = make_response(
        content=(
            "I can shorten your workout to 20 minutes. "
            "Please confirm this change."
        )
    )

    responses = iter(
        [
            first_response,
            second_response,
        ]
    )

    monkeypatch.setattr(
        agent.groq,
        "chat",
        lambda messages, tools=None: next(responses),
    )

    response = agent.chat(
        user_id="test-user-001",
        conversation_id="tool-test-003",
        message="I only have 20 minutes today. Shorten my workout.",
    )

    assert response.requires_confirmation is True
    assert len(response.actions) == 1

    action = response.actions[0]

    assert action.type == "modify_workout"
    assert action.status == "pending_confirmation"
    assert action.target_id == "workout-001"
    assert action.arguments["change_type"] == "reduce_duration"
    assert action.arguments["value"] == 20


def test_write_tool_handler_is_not_called_without_confirmation(
    monkeypatch,
):
    agent = FitnessAgent()

    def forbidden_handler(**kwargs):
        raise AssertionError(
            "Write handler must not execute without confirmation."
        )

    tool = agent.tool_registry.get("modify_workout")

    assert tool is not None

    from app.tools.registry import ToolDefinition

    replacement_tool = ToolDefinition(
        name=tool.name,
        description=tool.description,
        input_model=tool.input_model,
        handler=forbidden_handler,
        permission=tool.permission,
    )

    monkeypatch.setitem(
        agent.tool_registry._tools,
        "modify_workout",
        replacement_tool,
    )

    first_response = make_response(
        tool_calls=[
            make_tool_call(
                tool_id="call-write-002",
                tool_name="modify_workout",
                arguments=(
                    '{"workout_id":"workout-001",'
                    '"change_type":"reduce_duration",'
                    '"value":20,'
                    '"reason":"User requested a shorter workout."}'
                ),
            )
        ]
    )

    second_response = make_response(
        content=(
            "I can shorten your workout to 20 minutes. "
            "Please confirm this change."
        )
    )

    responses = iter(
        [
            first_response,
            second_response,
        ]
    )

    monkeypatch.setattr(
        agent.groq,
        "chat",
        lambda messages, tools=None: next(responses),
    )

    response = agent.chat(
        user_id="test-user-001",
        conversation_id="tool-test-004",
        message="Shorten my workout to 20 minutes.",
    )

    assert response.requires_confirmation is True
    assert len(response.actions) == 1
    assert response.actions[0].status == "pending_confirmation"