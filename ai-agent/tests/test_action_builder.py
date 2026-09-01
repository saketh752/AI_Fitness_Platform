from app.agent.action_builder import ActionBuilder


def test_workout_action_requires_confirmation():
    action = ActionBuilder.confirmation_action(
        "modify_workout",
        {
            "workout_id": "workout-001",
            "change_type": "reduce_duration",
            "value": 20,
            "reason": "User has limited time.",
        },
    )

    assert action.type == "modify_workout"
    assert action.status == "pending_confirmation"
    assert action.target_id == "workout-001"


def test_meal_plan_action_requires_confirmation():
    action = ActionBuilder.confirmation_action(
        "modify_meal_plan",
        {
            "meal_plan_id": "meal-plan-001",
            "change_type": "replace_meal",
            "target_meal": "lunch",
            "replacement": "vegetable rice bowl",
            "reason": "User requested a meal replacement.",
        },
    )

    assert action.type == "modify_meal_plan"
    assert action.status == "pending_confirmation"
    assert action.target_id == "meal-plan-001"