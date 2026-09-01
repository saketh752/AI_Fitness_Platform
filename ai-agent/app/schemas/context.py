from pydantic import BaseModel, Field


class UserProfileContext(BaseModel):
    age: int | None = None
    height_cm: float | None = None
    weight_kg: float | None = None
    fitness_level: str | None = None
    activity_level: str | None = None


class FitnessGoalsContext(BaseModel):
    primary_goal: str | None = None
    target_weight_kg: float | None = None
    target_date: str | None = None


class FitnessConstraintsContext(BaseModel):
    available_time_minutes: int | None = None
    equipment: list[str] = Field(default_factory=list)
    dietary_preferences: list[str] = Field(default_factory=list)
    excluded_exercises: list[str] = Field(default_factory=list)


class WorkoutContext(BaseModel):
    workout_id: str | None = None
    workout_name: str | None = None
    duration_minutes: int | None = None
    exercises: list[dict] = Field(default_factory=list)


class NutritionContext(BaseModel):
    meal_plan_id: str | None = None
    daily_calorie_target: int | None = None
    meals: list[dict] = Field(default_factory=list)


class ProgressContext(BaseModel):
    recent_weight_kg: list[float] = Field(default_factory=list)
    completed_workouts: int = 0
    progress_summary: str | None = None


class FitnessContext(BaseModel):
    profile: UserProfileContext | None = None
    goals: FitnessGoalsContext | None = None
    constraints: FitnessConstraintsContext | None = None
    workout: WorkoutContext | None = None
    nutrition: NutritionContext | None = None
    progress: ProgressContext | None = None