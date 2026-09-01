import json

import pytest

from app.tools.default_registry import create_default_registry
from app.tools.executor import ToolExecutionError, ToolExecutor


def test_valid_tool_execution():
    registry = create_default_registry()
    executor = ToolExecutor(registry)

    result = executor.execute(
        "get_workout",
        json.dumps(
            {
                "workout_id": "workout-001",
            }
        ),
    )

    assert result["status"] == "mock"


def test_unknown_tool_is_rejected():
    registry = create_default_registry()
    executor = ToolExecutor(registry)

    with pytest.raises(ToolExecutionError):
        executor.execute(
            "execute_python",
            "{}",
        )


def test_invalid_arguments_are_rejected():
    registry = create_default_registry()
    executor = ToolExecutor(registry)

    with pytest.raises(ToolExecutionError):
        executor.execute(
            "modify_workout",
            json.dumps(
                {
                    "workout_id": "workout-001",
                    "change_type": "delete_everything",
                    "reason": "malicious test",
                }
            ),
        )


def test_malformed_json_is_rejected():
    registry = create_default_registry()
    executor = ToolExecutor(registry)

    with pytest.raises(ToolExecutionError):
        executor.execute(
            "get_workout",
            "this is not json",
        )
        def test_read_tool_executes_without_confirmation():
          registry = create_default_registry()
    executor = ToolExecutor(registry)

    result = executor.execute(
        "get_workout",
        json.dumps(
            {
                "workout_id": "workout-001",
            }
        ),
    )

    assert result["status"] == "mock"


def test_write_tool_requires_confirmation():
    registry = create_default_registry()
    executor = ToolExecutor(registry)

    result = executor.execute(
        "modify_workout",
        json.dumps(
            {
                "workout_id": "workout-001",
                "change_type": "reduce_duration",
                "value": 20,
                "reason": "User only has 20 minutes.",
            }
        ),
    )

    assert result["status"] == "confirmation_required"


def test_confirmed_write_tool_can_execute():
    registry = create_default_registry()
    executor = ToolExecutor(registry)

    result = executor.execute(
        "modify_workout",
        json.dumps(
            {
                "workout_id": "workout-001",
                "change_type": "reduce_duration",
                "value": 20,
                "reason": "User confirmed the shorter workout.",
            }
        ),
        confirmed=True,
    )

    assert result["status"] == "mock"