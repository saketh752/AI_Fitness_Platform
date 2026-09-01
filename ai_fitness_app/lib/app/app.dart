import 'package:flutter/material.dart';

import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/forgot_password_success_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';

import '../features/dashboard/presentation/dashboard_destination_placeholder.dart';
import '../features/dashboard/presentation/dashboard_shell_screen.dart';

import '../features/nutrition/models/meal.dart';
import '../features/nutrition/presentation/all_meals_screen.dart';
import '../features/nutrition/presentation/meal_details_screen.dart';
import '../features/nutrition/presentation/nutrition_overview_screen.dart';

import '../features/onboarding/presentation/onboarding_flow_screen.dart';
import '../features/onboarding/presentation/onboarding_remaining_flow_screen.dart';

import '../features/plan_generation/presentation/plan_generation_loading_screen.dart';
import '../features/plan_generation/presentation/plan_ready_success_screen.dart';

import '../features/splash/presentation/splash_screen.dart';

import '../features/workouts/presentation/active_workout_screen.dart';
import '../features/form_analysis/presentation/live_form_analysis_screen.dart';
import '../features/workouts/presentation/workout_complete_screen.dart';
import '../features/workouts/presentation/workout_details_screen.dart';
import '../features/workouts/presentation/workout_overview_screen.dart';
import '../features/workouts/presentation/workout_plan_state.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/ai_coach/presentation/ai_coach_screen.dart';

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class AiFitnessApp extends StatelessWidget {
  const AiFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Fitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),

        AppRoutes.welcome: (context) => const WelcomeScreen(),

        AppRoutes.signup: (context) => const SignUpScreen(),

        AppRoutes.login: (context) => const LoginScreen(),

        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),

        AppRoutes.forgotPasswordSuccess: (context) =>
            const ForgotPasswordSuccessScreen(),

        AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),

        AppRoutes.onboardingIntroduction: (context) =>
            const OnboardingFlowScreen(screen: OnboardingScreen.introduction),

        AppRoutes.onboardingFitnessGoal: (context) =>
            const OnboardingFlowScreen(screen: OnboardingScreen.fitnessGoal),

        AppRoutes.onboardingFitnessContext: (context) =>
            const OnboardingFlowScreen(screen: OnboardingScreen.fitnessContext),

        AppRoutes.onboardingBasicProfile: (context) =>
            const OnboardingFlowScreen(screen: OnboardingScreen.basicProfile),

        AppRoutes.onboardingAvailableEquipment: (context) =>
            const OnboardingFlowScreen(screen: OnboardingScreen.equipment),

        AppRoutes.onboardingFoodAvailability: (context) =>
            const OnboardingRemainingFlowScreen(
              screen: RemainingOnboardingScreen.food,
            ),

        AppRoutes.onboardingBudget: (context) =>
            const OnboardingRemainingFlowScreen(
              screen: RemainingOnboardingScreen.budget,
            ),

        AppRoutes.onboardingTime: (context) =>
            const OnboardingRemainingFlowScreen(
              screen: RemainingOnboardingScreen.time,
            ),

        AppRoutes.onboardingReview: (context) =>
            const OnboardingRemainingFlowScreen(
              screen: RemainingOnboardingScreen.review,
            ),

        AppRoutes.planGenerationLoading: (context) =>
            const PlanGenerationLoadingScreen(),

        AppRoutes.planReady: (context) => const PlanReadySuccessScreen(),

        AppRoutes.home: (context) => const DashboardShellScreen(),

        AppRoutes.workoutOverview: (context) => const WorkoutOverviewScreen(),

        AppRoutes.nutritionOverview: (context) =>
            const NutritionOverviewScreen(),

        AppRoutes.allMeals: (context) => const AllMealsScreen(),

        AppRoutes.progressOverview: (context) =>
            const DashboardDestinationPlaceholder(title: 'Progress Overview'),

        AppRoutes.profile: (context) => const ProfileScreen(),

        AppRoutes.editProfile: (context) => const EditProfileScreen(),

        AppRoutes.settings: (context) => const SettingsScreen(),

        AppRoutes.aiCoach: (context) => const AiCoachScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.workoutDetails) {
          final workout = settings.arguments is WorkoutItem
              ? settings.arguments! as WorkoutItem
              : WorkoutPlanState.today;

          return MaterialPageRoute(
            builder: (context) => WorkoutDetailsScreen(workout: workout),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.activeWorkout) {
          final workout = settings.arguments is WorkoutItem
              ? settings.arguments! as WorkoutItem
              : WorkoutPlanState.today;

          return MaterialPageRoute(
            builder: (context) => ActiveWorkoutScreen(workout: workout),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.workoutComplete) {
          final workout = settings.arguments is WorkoutItem
              ? settings.arguments! as WorkoutItem
              : WorkoutPlanState.today;

          return MaterialPageRoute(
            builder: (context) => WorkoutCompleteScreen(workout: workout),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.formAnalysis) {
          final exercise = settings.arguments is ExerciseItem
              ? settings.arguments! as ExerciseItem
              : WorkoutPlanState.today.exercises.first;

          return MaterialPageRoute(
            builder: (context) =>
                LiveFormAnalysisScreen(exercise: exercise),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.mealDetails) {
          final meal = settings.arguments;

          if (meal is Meal) {
            return MaterialPageRoute(
              builder: (context) => MealDetailsScreen(meal: meal),
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder: (context) =>
                const DashboardDestinationPlaceholder(title: 'Meal Details'),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
