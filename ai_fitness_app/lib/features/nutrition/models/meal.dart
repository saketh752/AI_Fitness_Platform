enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeLabel on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class Meal {
  final String id;
  final MealType type;
  final String name;
  final int calories;
  final int protein;
  final int? carbs;
  final int? fat;
  final List<String> ingredients;
  final String? imageAsset;
  bool isEaten;

  Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    this.carbs,
    this.fat,
    this.ingredients = const [],
    this.imageAsset,
    this.isEaten = false,
  });
}
