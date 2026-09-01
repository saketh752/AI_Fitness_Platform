import 'package:ai_fitness_app/features/auth/domain/auth_session_store.dart';
import 'package:ai_fitness_app/features/dashboard/presentation/dashboard_shell_screen.dart';
import 'package:ai_fitness_app/features/nutrition/presentation/nutrition_overview_screen.dart';
import 'package:ai_fitness_app/features/Progress/presentation/progress_overview_screen.dart';
import 'package:ai_fitness_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:ai_fitness_app/features/profile/presentation/profile_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AuthSessionStore.clearSession();
    AuthSessionStore.saveSession(
      email: 'alex@example.com',
      name: 'Alex Johnson',
      token: 'jwt_test_token',
      userId: '1',
      onboardingComplete: true,
    );
  });

  group('DashboardShellScreen Widget Tests', () {
    testWidgets('renders all bottom navigation destinations and switches tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DashboardShellScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Workouts'), findsWidgets);
      expect(find.text('Nutrition'), findsWidgets);
      expect(find.text('Progress'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);

      // Verify home content
      expect(find.textContaining('Alex'), findsWidgets);
      expect(find.text('Start Workout'), findsOneWidget);

      // Switch to Workouts tab
      await tester.tap(find.text('Workouts'));
      await tester.pumpAndSettle();
      expect(find.text('Your Training Plan'), findsOneWidget);

      // Switch to Nutrition tab
      await tester.tap(find.text('Nutrition'));
      await tester.pumpAndSettle();
      expect(find.text("TODAY'S TARGET"), findsOneWidget);

      // Switch to Progress tab
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('Your Fitness Journey'), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('YOUR FITNESS PROFILE'), findsOneWidget);
    });
  });

  group('NutritionOverviewScreen Widget Tests', () {
    testWidgets('renders macro targets and today meal list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NutritionOverviewScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text("TODAY'S TARGET"), findsOneWidget);
      expect(find.text("TODAY'S MACROS"), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      expect(find.text("TODAY'S MEALS"), findsOneWidget);
    });
  });

  group('ProgressOverviewScreen Widget Tests', () {
    testWidgets('renders streak, metrics, and weight log dialog trigger', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProgressOverviewScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('CURRENT STREAK'), findsOneWidget);
      expect(find.text('WORKOUT PROGRESS'), findsOneWidget);
      expect(find.text('TOTAL METRICS'), findsOneWidget);
      expect(find.text('WEIGHT LOGS'), findsOneWidget);

      // Open log weight dialog
      await tester.tap(find.byTooltip('Log Weight'));
      await tester.pumpAndSettle();

      expect(find.text('Log Body Weight'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Log Body Weight'), findsNothing);
    });
  });

  group('Profile & EditProfileScreen Widget Tests', () {
    testWidgets('ProfileOverviewScreen renders user header and profile attributes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileOverviewScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('YOUR FITNESS PROFILE'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('EditProfileScreen allows input editing and renders save button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: EditProfileScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Current Weight (kg)'), findsOneWidget);
      expect(find.text('Height (cm)'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}

