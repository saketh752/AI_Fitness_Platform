from app.schemas.tools import (
    GetNutritionInput,
    GetProgressInput,
    GetUserGoalsInput,
    GetUserProfileInput,
    GetWorkoutHistoryInput,
    GetWorkoutInput,
    ModifyMealPlanInput,
    ModifyWorkoutInput,
    UpdateGoalInput,
)
from app.tools.handlers import (
    get_nutrition,
    get_progress,
    get_user_goals,
    get_user_profile,
    get_workout,
    get_workout_history,
    modify_meal_plan,
    modify_workout,
    update_goal,
)
from app.tools.registry import ToolDefinition, ToolRegistry


def create_default_registry() -> ToolRegistry:
    registry = ToolRegistry()

    registry.register(
        ToolDefinition(
            name="get_workout",
            description="Retrieve the user's current workout.",
            input_model=GetWorkoutInput,
            handler=get_workout,
            permission="read",
        )
    )

    registry.register(
        ToolDefinition(
            name="get_nutrition",
            description="Retrieve the user's current nutrition plan.",
            input_model=GetNutritionInput,
            handler=get_nutrition,
            permission="read",
        )
    )

    registry.register(
        ToolDefinition(
            name="get_user_profile",
            description="Retrieve the user's fitness profile.",
            input_model=GetUserProfileInput,
            handler=get_user_profile,
            permission="read",
        )
    )

    registry.register(
        ToolDefinition(
            name="get_user_goals",
            description="Retrieve the user's fitness goals.",
            input_model=GetUserGoalsInput,
            handler=get_user_goals,
            permission="read",
        )
    )

    registry.register(
        ToolDefinition(
            name="get_progress",
            description="Retrieve the user's recent fitness progress.",
            input_model=GetProgressInput,
            handler=get_progress,
            permission="read",
        )
    )

    registry.register(
        ToolDefinition(
            name="get_workout_history",
            description="Retrieve the user's recent workout history.",
            input_model=GetWorkoutHistoryInput,
            handler=get_workout_history,
            permission="read",
        )
    )

    registry.register(
        ToolDefinition(
            name="modify_workout",
            description="Request an allowed modification to the user's workout.",
            input_model=ModifyWorkoutInput,
            handler=modify_workout,
            permission="write",
        )
    )

    registry.register(
        ToolDefinition(
            name="modify_meal_plan",
            description="Request an allowed modification to the user's meal plan.",
            input_model=ModifyMealPlanInput,
            handler=modify_meal_plan,
            permission="write",
        )
    )

    registry.register(
        ToolDefinition(
            name="update_goal",
            description="Request an update to the user's primary fitness goal.",
            input_model=UpdateGoalInput,
            handler=update_goal,
            permission="write",
        )
    )

    return registry