class AppRoutes {
  AppRoutes._();

  static const String splash = '/';

  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordSuccess = '/forgot-password-success';
  static const String resetPassword = '/reset-password';

  static const String onboardingIntroduction = '/onboarding/introduction';
  static const String onboardingFitnessGoal = '/onboarding/fitness-goal';
  static const String onboardingFitnessContext = '/onboarding/fitness-context';
  static const String onboardingBasicProfile = '/onboarding/basic-profile';
  static const String onboardingAvailableEquipment =
      '/onboarding/available-equipment';
  static const String onboardingFoodAvailability =
      '/onboarding/food-availability';
  static const String onboardingBudget = '/onboarding/budget';
  static const String onboardingTime = '/onboarding/time';
  static const String onboardingReview = '/onboarding/review';

  static const String home = '/home';

  static const String planGenerationLoading = '/plan-generation/loading';
  static const String planReady = '/plan-generation/ready';

  static const String workoutDetails = '/workouts/today';
  static const String activeWorkout = '/workouts/active';
  static const String workoutComplete = '/workouts/complete';
  static const String formAnalysis = '/workouts/form-analysis';
  static const String workoutOverview = '/workouts';

  static const String nutritionOverview = '/nutrition';
  static const String allMeals = '/nutrition/meals';
  static const String mealDetails = '/nutrition/meal';

  static const String progressOverview = '/progress';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String aiCoach = '/ai-coach';
}
