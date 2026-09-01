import '../models/meal.dart';

class NutritionState {
  NutritionState._();

  static final List<Meal> meals = [
    Meal(
      id: 'breakfast',
      type: MealType.breakfast,
      name: 'Oats & Banana',
      calories: 420,
      protein: 18,
    ),
    Meal(
      id: 'lunch',
      type: MealType.lunch,
      name: 'Grilled Chicken Salad & Rice',
      calories: 540,
      protein: 42,
      carbs: 58,
      fat: 16,
      ingredients: [
        'Grilled Chicken',
        'Rice',
        'Lettuce & Vegetables',
        'Dressing',
      ],
    ),
    Meal(
      id: 'dinner',
      type: MealType.dinner,
      name: 'Paneer & Roti',
      calories: 610,
      protein: 32,
    ),
    Meal(
      id: 'snack',
      type: MealType.snack,
      name: 'Greek Yogurt',
      calories: 180,
      protein: 15,
    ),
  ];

  static Meal? findMeal(String id) {
    for (final meal in meals) {
      if (meal.id == id) {
        return meal;
      }
    }

    return null;
  }

  static void markAsEaten(String id) {
    final meal = findMeal(id);

    if (meal != null) {
      meal.isEaten = true;
    }
  }
}
