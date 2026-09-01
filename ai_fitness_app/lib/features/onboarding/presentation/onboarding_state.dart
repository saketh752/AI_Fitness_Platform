class OnboardingData {
  OnboardingData._();

  static String name = 'Your name';
  static String gender = 'Prefer not to say';
  static String age = '28';
  static String height = '175 cm';
  static String weight = '70 kg';
  static String goal = 'Not selected';
  static String fitnessLevel = 'Not selected';
  static final Set<String> equipment = <String>{};
  static final Set<String> foods = <String>{};
  static String otherFood = '';
  static String budget = 'Not selected';
  static String customBudget = '';
  static String workoutFrequency = 'Not selected';
  static String preferredDuration = 'Not selected';
  static String customDuration = '';

  static void reset() {
    name = 'Your name';
    gender = 'Prefer not to say';
    age = '28';
    height = '175 cm';
    weight = '70 kg';
    goal = 'Not selected';
    fitnessLevel = 'Not selected';
    equipment.clear();
    foods.clear();
    otherFood = '';
    budget = 'Not selected';
    customBudget = '';
    workoutFrequency = 'Not selected';
    preferredDuration = 'Not selected';
    customDuration = '';
  }

  static String get budgetLabel =>
      budget == 'Custom Amount' && customBudget.isNotEmpty
      ? '₹$customBudget'
      : budget;

  static String get equipmentLabel =>
      equipment.isEmpty ? 'Not selected' : equipment.join(', ');
  static String get foodLabel => foods.isEmpty
      ? 'Not selected'
      : foods
            .map(
              (food) =>
                  food == 'Other / Limited Options' && otherFood.isNotEmpty
                  ? '$food: $otherFood'
                  : food,
            )
            .join(', ');
  static String get timeLabel =>
      workoutFrequency == 'Not selected' || preferredDuration == 'Not selected'
      ? 'Not selected'
      : '$workoutFrequency, ${preferredDuration == 'Custom minutes' && customDuration.isNotEmpty ? '$customDuration min' : preferredDuration}';
}
