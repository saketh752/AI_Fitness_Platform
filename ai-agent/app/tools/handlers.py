def get_workout(workout_id: str) -> dict:
    return {
        "status": "mock",
        "workout_id": workout_id,
        "workout_name": "Upper Body",
        "duration_minutes": 45,
        "exercises": [
            {
                "name": "Dumbbell Bench Press",
                "sets": 3,
                "reps": 10,
            },
            {
                "name": "One Arm Dumbbell Row",
                "sets": 3,
                "reps": 10,
            },
        ],
    }


def get_nutrition(meal_plan_id: str) -> dict:
    return {
        "status": "mock",
        "meal_plan_id": meal_plan_id,
        "daily_calorie_target": 2200,
        "meals": [
            {
                "meal": "breakfast",
                "name": "Oats and fruit",
            },
            {
                "meal": "lunch",
                "name": "Rice, vegetables and protein",
            },
            {
                "meal": "dinner",
                "name": "Chapati and protein",
            },
        ],
    }


def get_user_profile(user_id: str) -> dict:
    return {
        "status": "mock",
        "user_id": user_id,
        "fitness_level": "intermediate",
        "activity_level": "moderate",
    }


def get_user_goals(user_id: str) -> dict:
    return {
        "status": "mock",
        "user_id": user_id,
        "primary_goal": "muscle_gain",
        "target_weight_kg": 75,
    }


def get_progress(user_id: str) -> dict:
    return {
        "status": "mock",
        "user_id": user_id,
        "completed_workouts": 18,
        "recent_weight_kg": [71.5, 72.0, 72.4],
        "progress_summary": "Consistent training with gradual weight gain.",
    }


def get_workout_history(
    user_id: str,
    limit: int,
) -> dict:
    return {
        "status": "mock",
        "user_id": user_id,
        "limit": limit,
        "workouts": [
            {
                "workout_id": "workout-001",
                "name": "Upper Body",
                "completed": True,
            },
            {
                "workout_id": "workout-002",
                "name": "Lower Body",
                "completed": True,
            },
        ],
    }


def modify_workout(**kwargs) -> dict:
    return {
        "status": "mock",
        "message": "Workout modification accepted for testing.",
        "requested_change": kwargs,
    }


def modify_meal_plan(**kwargs) -> dict:
    return {
        "status": "mock",
        "message": "Meal plan modification accepted for testing.",
        "requested_change": kwargs,
    }


def update_goal(**kwargs) -> dict:
    return {
        "status": "mock",
        "message": "Goal update accepted for testing.",
        "requested_change": kwargs,
    }