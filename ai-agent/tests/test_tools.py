import pytest
from pydantic import ValidationError

from app.schemas.tools import ModifyWorkoutInput
from app.tools.default_registry import create_default_registry


def test_default_registry_contains_only_allowed_tools():
    registry = create_default_registry()

    assert set(registry.names()) == {
        "get_workout",
        "get_nutrition",
        "get_user_profile",
        "get_user_goals",
        "get_progress",
        "get_workout_history",
        "modify_workout",
        "modify_meal_plan",
        "update_goal",
    }


def test_unknown_tool_is_not_available():
    registry = create_default_registry()

    assert registry.get("execute_python") is None
    assert registry.get("run_shell_command") is None
    assert registry.get("database_query") is None
    assert registry.get("delete_database") is None


def test_all_registered_tools_have_permissions():
    registry = create_default_registry()

    for tool_name in registry.names():
        tool = registry.get(tool_name)

        assert tool is not None
        assert tool.permission in {"read", "write"}


def test_read_tools_are_read_only():
    registry = create_default_registry()

    read_tools = {
        "get_workout",
        "get_nutrition",
        "get_user_profile",
        "get_user_goals",
        "get_progress",
        "get_workout_history",
    }

    for tool_name in read_tools:
        tool = registry.get(tool_name)

        assert tool is not None
        assert tool.permission == "read"


def test_write_tools_are_write_only():
    registry = create_default_registry()

    write_tools = {
        "modify_workout",
        "modify_meal_plan",
        "update_goal",
    }

    for tool_name in write_tools:
        tool = registry.get(tool_name)

        assert tool is not None
        assert tool.permission == "write"


def test_workout_modification_requires_valid_change_type():
    with pytest.raises(ValidationError):
        ModifyWorkoutInput(
            workout_id="workout-001",
            change_type="delete_entire_workout",
            reason="Testing",
        )


def test_valid_workout_modification():
    request = ModifyWorkoutInput(
        workout_id="workout-001",
        change_type="reduce_duration",
        value=20,
        reason="User only has 20 minutes today.",
    )

    assert request.change_type == "reduce_duration"