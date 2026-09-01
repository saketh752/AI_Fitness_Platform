import 'package:ai_fitness_app/app/routes/app_routes.dart';
import 'package:ai_fitness_app/features/workouts/presentation/active_workout_screen.dart';
import 'package:ai_fitness_app/features/form_analysis/presentation/live_form_analysis_screen.dart';
import 'package:ai_fitness_app/features/workouts/presentation/workout_complete_screen.dart';
import 'package:ai_fitness_app/features/workouts/presentation/workout_details_screen.dart';
import 'package:ai_fitness_app/features/workouts/presentation/workout_overview_screen.dart';
import 'package:ai_fitness_app/features/workouts/presentation/workout_plan_state.dart';
import 'package:ai_fitness_app/features/workouts/presentation/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    WorkoutPlanState.reset();
    WorkoutSessionStore.clearAll();
  });

  tearDown(() {
    WorkoutPlanState.reset();
    WorkoutSessionStore.clearAll();
  });

  group('WorkoutSession Unit Tests', () {
    test('initializes with correct defaults for Push Day', () {
      final session = WorkoutSession(WorkoutPlanState.today);
      expect(session.currentExerciseIndex, 0);
      expect(session.currentSetIndex, 0);
      expect(session.status, WorkoutSessionStatus.ready);
      expect(session.exercise.name, 'Barbell Bench Press');
      expect(session.exerciseSets.length, 6);
      expect(session.exerciseSets[0].length, 3);
      expect(session.exerciseSets[0][0].weightKg, 60.0);
      expect(session.exerciseSets[0][0].reps, 10);
      expect(session.exerciseSets[0][0].isCompleted, isFalse);
      expect(session.exerciseSets[1][0].weightKg, 20.0);
    });

    test('completeCurrentSet updates completed status and handles editing', () {
      final session = WorkoutSession(WorkoutPlanState.today);
      session.updateWeight(0, 0, 65.0);
      session.updateReps(0, 0, 12);
      expect(session.exerciseSets[0][0].weightKg, 65.0);
      expect(session.exerciseSets[0][0].reps, 12);

      session.completeCurrentSet();
      expect(session.exerciseSets[0][0].isCompleted, isTrue);
      expect(session.completedSets[0][0], isTrue);
    });

    test('WorkoutSessionStore preserves state across queries and clears on demand', () {
      final session1 = WorkoutSessionStore.forWorkout(WorkoutPlanState.today);
      session1.currentExerciseIndex = 2;
      session1.currentSetIndex = 1;
      session1.completeCurrentSet();

      final session2 = WorkoutSessionStore.forWorkout(WorkoutPlanState.today);
      expect(identical(session1, session2), isTrue);
      expect(session2.currentExerciseIndex, 2);
      expect(session2.currentSetIndex, 1);
      expect(session2.exerciseSets[2][1].isCompleted, isTrue);

      WorkoutSessionStore.clear(WorkoutPlanState.today.id);
      final session3 = WorkoutSessionStore.forWorkout(WorkoutPlanState.today);
      expect(session3.currentExerciseIndex, 0);
      expect(session3.currentSetIndex, 0);
    });
  });

  group('WorkoutPlanState Shared State Tests', () {
    test('markTodayCompleted updates completedWorkouts and completion', () {
      expect(WorkoutPlanState.completedWorkouts, 3);
      expect(WorkoutPlanState.completion, 0.75);
      expect(WorkoutPlanState.today.status, WorkoutStatus.upcoming);

      WorkoutPlanState.markTodayCompleted();

      expect(WorkoutPlanState.completedWorkouts, 4);
      expect(WorkoutPlanState.completion, 1.0);
      expect(WorkoutPlanState.today.status, WorkoutStatus.completed);
      expect(WorkoutPlanState.schedule[0].status, WorkoutStatus.completed);
    });

    test('all 6 push exercises have registered imageAsset illustrations', () {
      final exercises = WorkoutPlanState.today.exercises;
      expect(exercises.length, 6);
      for (final ex in exercises) {
        expect(ex.imageAsset, isNotEmpty, reason: '${ex.name} missing imageAsset');
        expect(ex.imageAsset, startsWith('assets/images/exercises/'));
      }
      expect(exercises[0].imageAsset, contains('barbell_bench_press'));
      expect(exercises[1].imageAsset, contains('incline_dumbbell_press'));
      expect(exercises[2].imageAsset, contains('chest_fly'));
      expect(exercises[3].imageAsset, contains('dumbbell_shoulder_press'));
      expect(exercises[4].imageAsset, contains('tricep_pushdown'));
      expect(exercises[5].imageAsset, contains('tricep_extension'));
    });
  });

  group('WorkoutDetailsScreen Asset Tests', () {
    testWidgets('renders decorative penguin GIF in exercise card area', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WorkoutDetailsScreen(workout: WorkoutPlanState.today),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/characters/penguin_bench_press.gif');
      expect(find.text('Start Workout'), findsOneWidget);
    });
  });

  group('ActiveWorkoutScreen Widget Flow Tests', () {
    Widget buildTestWidget({WorkoutItem? workout}) {
      return MaterialApp(
        routes: {
          AppRoutes.workoutOverview: (_) => const WorkoutOverviewScreen(),
          AppRoutes.activeWorkout: (_) =>
              ActiveWorkoutScreen(workout: workout ?? WorkoutPlanState.today),
        },
        home: ActiveWorkoutScreen(workout: workout ?? WorkoutPlanState.today),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.formAnalysis) {
            final exercise = settings.arguments as ExerciseItem;
            return MaterialPageRoute(
              builder: (_) => LiveFormAnalysisScreen(exercise: exercise),
            );
          }
          if (settings.name == AppRoutes.workoutComplete) {
            final w = settings.arguments as WorkoutItem;
            return MaterialPageRoute(
              builder: (_) => WorkoutCompleteScreen(workout: w),
            );
          }
          if (settings.name == AppRoutes.workoutOverview) {
            return MaterialPageRoute(
              builder: (_) => const WorkoutOverviewScreen(),
            );
          }
          return null;
        },
      );
    }

    testWidgets('renders initial active workout elements correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, contains('barbell_bench_press'));
      expect(find.text('Analyze Form'), findsOneWidget);
      expect(find.text('Complete Set'), findsOneWidget);
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text('REPS'), findsOneWidget);
      expect(find.text('60 kg'), findsNWidgets(3));
    });

    testWidgets('Analyze Form navigates to Form Analysis with current exercise', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Analyze Form'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Barbell Bench Press'), findsWidgets);
      expect(find.text('REPS'), findsWidgets);
      expect(find.text('Finish Form Analysis'), findsOneWidget);
    });

    testWidgets('Complete Set enters REST state with 01:30 countdown, and Skip Rest advances', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap Complete Set on Set 1
      await tester.tap(find.text('Complete Set'));
      await tester.pump();

      // Verify Rest state UI
      expect(find.text('REST'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('Take a breather'), findsOneWidget);
      expect(find.text('Skip Rest'), findsOneWidget);

      // Verify Complete Set is not visible while resting
      expect(find.text('Complete Set'), findsNothing);

      // Tap Skip Rest
      await tester.tap(find.text('Skip Rest'));
      await tester.pump();

      // Now on Set 2, ready state
      expect(find.text('REST'), findsNothing);
      expect(find.text('Complete Set'), findsOneWidget);
    });

    testWidgets('Interactive weight and reps editing works', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Scroll to table and ensure first weight item is visible
      final weightFinder = find.text('60 kg').first;
      await tester.ensureVisible(weightFinder);
      await tester.pumpAndSettle();

      await tester.tap(weightFinder);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Edit Set 1 Weight'), findsOneWidget);
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, '70');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify updated weight
      expect(find.text('70 kg'), findsOneWidget);
    });

    testWidgets('Exercise Complete state appears after final set, Next Exercise advances', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Set 1
      await tester.tap(find.text('Complete Set'));
      await tester.pump();
      await tester.tap(find.text('Skip Rest'));
      await tester.pump();

      // Set 2
      await tester.tap(find.text('Complete Set'));
      await tester.pump();
      await tester.tap(find.text('Skip Rest'));
      await tester.pump();

      // Set 3 (final set of exercise 1)
      await tester.tap(find.text('Complete Set'));
      await tester.pumpAndSettle();

      // Verify Exercise Complete state
      expect(find.text('Exercise complete'), findsOneWidget);
      expect(find.text('Great work!'), findsOneWidget);
      expect(find.text('Next Exercise →'), findsOneWidget);

      // Tap Next Exercise
      await tester.tap(find.text('Next Exercise →'));
      await tester.pumpAndSettle();

      // Now on Exercise 2
      expect(find.text('2/6'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
      final imageWidget2 = tester.widget<Image>(find.byType(Image));
      final assetImage2 = imageWidget2.image as AssetImage;
      expect(assetImage2.assetName, contains('incline_dumbbell_press'));
      expect(find.text('20 kg'), findsNWidgets(3));
      expect(find.text('Complete Set'), findsOneWidget);
    });

    testWidgets('Leave dialog confirms and saves progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.workoutOverview: (_) => const WorkoutOverviewScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.workoutDetails) {
              final w =
                  (settings.arguments as WorkoutItem?) ?? WorkoutPlanState.today;
              return MaterialPageRoute(
                builder: (_) => WorkoutDetailsScreen(workout: w),
                settings: settings,
              );
            }
            if (settings.name == AppRoutes.activeWorkout) {
              final w =
                  (settings.arguments as WorkoutItem?) ?? WorkoutPlanState.today;
              return MaterialPageRoute(
                builder: (_) => ActiveWorkoutScreen(workout: w),
                settings: settings,
              );
            }
            return null;
          },
          initialRoute: AppRoutes.workoutOverview,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Start Workout on Overview to open WorkoutDetailsScreen
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Tap Start Workout on Details to open ActiveWorkoutScreen
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Complete Set 1
      await tester.tap(find.text('Complete Set'));
      await tester.pump();
      await tester.tap(find.text('Skip Rest'));
      await tester.pump();

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Leave Workout?'), findsOneWidget);
      expect(find.text('Your current progress will be saved.'), findsOneWidget);

      // Tap Stay
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);

      // Tap back again and tap Leave
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      // Returned to Workout Overview
      expect(find.text('Your Training Plan'), findsOneWidget);

      // Verify session was saved
      final session = WorkoutSessionStore.forWorkout(WorkoutPlanState.today);
      expect(session.currentExerciseIndex, 0);
      expect(session.currentSetIndex, 1);
      expect(session.exerciseSets[0][0].isCompleted, isTrue);
    });
  });

  group('WorkoutCompleteScreen Tests', () {
    testWidgets('renders workout complete summary and updates state on Done', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.workoutOverview: (_) => const WorkoutOverviewScreen(),
          },
          home: WorkoutCompleteScreen(workout: WorkoutPlanState.today),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1100));

      expect(find.text('Workout Complete!'), findsOneWidget);
      expect(find.textContaining('Great work, Arjun! 👏'), findsOneWidget);
      expect(find.textContaining('Push Day workout.'), findsOneWidget);
      expect(find.text('WORKOUT SUMMARY'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('320 kcal'), findsOneWidget);
      expect(find.text('Dumbbells & Bench'), findsOneWidget);
      expect(find.text('🔥  5 Day Streak'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Done
      final doneFinder = find.text('Done');
      await tester.ensureVisible(doneFinder);
      await tester.pumpAndSettle();
      await tester.tap(doneFinder);
      await tester.pumpAndSettle();

      // Shared state updated
      expect(WorkoutPlanState.pushWorkoutCompleted, isTrue);
      expect(WorkoutPlanState.completedWorkouts, 4);

      // Workout Overview screen is now visible reflecting completion
      expect(find.text('4 of 4 workouts'), findsOneWidget);
      expect(find.text('Workout Complete'), findsOneWidget);
    });
  });
}
