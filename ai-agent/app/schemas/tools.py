from typing import Literal

from pydantic import BaseModel, Field


class GetWorkoutInput(BaseModel):
    workout_id: str = Field(min_length=1)


class GetNutritionInput(BaseModel):
    meal_plan_id: str = Field(min_length=1)


class GetUserProfileInput(BaseModel):
    user_id: str = Field(min_length=1)


class GetUserGoalsInput(BaseModel):
    user_id: str = Field(min_length=1)


class GetProgressInput(BaseModel):
    user_id: str = Field(min_length=1)


class GetWorkoutHistoryInput(BaseModel):
    user_id: str = Field(min_length=1)
    limit: int = Field(default=10, ge=1, le=50)


class ModifyWorkoutInput(BaseModel):
    workout_id: str = Field(min_length=1)
    change_type: Literal[
        "reduce_duration",
        "replace_exercise",
        "change_sets",
        "change_reps",
    ]
    target_exercise: str | None = None
    replacement_exercise: str | None = None
    value: int | None = None
    reason: str = Field(min_length=1, max_length=500)


class ModifyMealPlanInput(BaseModel):
    meal_plan_id: str = Field(min_length=1)
    change_type: Literal[
        "replace_meal",
        "adjust_calories",
        "remove_food",
    ]
    target_meal: str | None = None
    replacement: str | None = None
    value: int | None = None
    reason: str = Field(min_length=1, max_length=500)


class UpdateGoalInput(BaseModel):
    user_id: str = Field(min_length=1)
    primary_goal: str = Field(min_length=1, max_length=100)
    reason: str = Field(min_length=1, max_length=500)