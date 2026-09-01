import '../../onboarding/presentation/onboarding_state.dart';

class GeneratedPlanState {
  GeneratedPlanState._();

  static bool generated = false;

  static void markGenerated() {
    generated = true;
  }

  static String get workoutFrequency =>
      OnboardingData.workoutFrequency == 'Not selected'
      ? '4 days/week'
      : OnboardingData.workoutFrequency;

  static String get duration =>
      OnboardingData.preferredDuration == 'Not selected'
      ? '45 min'
      : OnboardingData.preferredDuration == 'Custom minutes'
      ? '${OnboardingData.customDuration} min'
      : OnboardingData.preferredDuration;

  static String get focus => OnboardingData.goal == 'Not selected'
      ? 'Build Muscle'
      : OnboardingData.goal;

  static String get nutritionTarget => '2,200 cal · High Protein';
  static String get userName =>
      OnboardingData.name == 'Your name' ? 'Arjun' : OnboardingData.name;
}
