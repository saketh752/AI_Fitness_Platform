import 'package:ai_fitness_app/core/network/api_client.dart';
import 'package:ai_fitness_app/features/ai_coach/data/coach_api_service.dart';
import 'package:ai_fitness_app/features/ai_coach/presentation/ai_coach_screen.dart';
import 'package:ai_fitness_app/features/auth/domain/auth_session_store.dart';
import 'package:ai_fitness_app/features/form_analysis/domain/exercise_form_evaluator.dart';
import 'package:ai_fitness_app/features/form_analysis/domain/joint_angle_calculator.dart';
import 'package:ai_fitness_app/features/form_analysis/presentation/live_form_analysis_screen.dart';
import 'package:ai_fitness_app/features/workouts/presentation/workout_plan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCoachApiClient extends ApiClient {
  FakeCoachApiClient() : super();

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    if (path == '/api/v1/coach/chat') {
      return {
        'success': true,
        'data': {
          'conversationId': 101,
          'status': 'SAFE',
          'response': 'Keep your back straight and push through your heels!',
        },
      };
    }
    return {'success': false};
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    if (path == '/api/v1/coach/history') {
      return {
        'success': true,
        'data': [
          {
            'id': 1,
            'message': 'How to improve squat depth?',
            'response': 'Warm up your hip flexors and ankles before squatting.',
            'status': 'SAFE',
          }
        ],
      };
    }
    return {'success': false};
  }
}

void main() {
  setUp(() {
    AuthSessionStore.clearSession();
    AuthSessionStore.saveSession(
      email: 'alex@example.com',
      name: 'Alex Johnson',
      token: 'jwt_mock_token',
      userId: '1',
      onboardingComplete: true,
    );
  });

  group('JointAngleCalculator Unit Tests', () {
    test('calculates 90 degree perpendicular angle accurately', () {
      final a = const Offset(0, 100);
      final b = const Offset(0, 0); // Vertex
      final c = const Offset(100, 0);

      final angle = JointAngleCalculator.calculateAngle(a, b, c);
      expect(angle, closeTo(90.0, 0.01));
    });

    test('calculates 180 degree straight line accurately', () {
      final a = const Offset(-100, 0);
      final b = const Offset(0, 0); // Vertex
      final c = const Offset(100, 0);

      final angle = JointAngleCalculator.calculateAngle(a, b, c);
      expect(angle, closeTo(180.0, 0.01));
    });
  });

  group('ExerciseFormEvaluator State Machine Tests', () {
    test('detects correct exercise type from names', () {
      expect(ExerciseFormEvaluator.detectType('Barbell Squat'), ExerciseType.squat);
      expect(ExerciseFormEvaluator.detectType('Push-ups'), ExerciseType.pushup);
      expect(ExerciseFormEvaluator.detectType('Dumbbell Bicep Curl'), ExerciseType.bicepCurl);
      expect(ExerciseFormEvaluator.detectType('Running'), ExerciseType.general);
    });

    test('Squat evaluator increments reps on full standing -> bottom -> standing cycle', () {
      final evaluator = ExerciseFormEvaluator(exerciseType: ExerciseType.squat);
      expect(evaluator.reps, 0);

      // 1. Standing (170 deg)
      evaluator.evaluateAngle(170.0);
      expect(evaluator.reps, 0);

      // 2. Bottom squat position (85 deg)
      final bottomResult = evaluator.evaluateAngle(85.0);
      expect(bottomResult.feedbackType, FormFeedbackType.good);
      expect(evaluator.reps, 0);

      // 3. Standing up (170 deg)
      final topResult = evaluator.evaluateAngle(170.0);
      expect(evaluator.reps, 1);
      expect(topResult.reps, 1);
      expect(topResult.formAccuracy, 100.0);
    });

    test('Pushup evaluator tracks elbow flexion rep cycle', () {
      final evaluator = ExerciseFormEvaluator(exerciseType: ExerciseType.pushup);

      // 1. Plank top position (160 deg)
      evaluator.evaluateAngle(160.0);
      expect(evaluator.reps, 0);

      // 2. Bottom chest to floor (80 deg)
      evaluator.evaluateAngle(80.0);
      expect(evaluator.reps, 0);

      // 3. Push back up (160 deg)
      final res = evaluator.evaluateAngle(160.0);
      expect(evaluator.reps, 1);
      expect(res.reps, 1);
    });
  });

  group('CoachApiService Unit Tests', () {
    test('sendMessage and getHistory parse API payloads correctly', () async {
      final service = CoachApiService(apiClient: FakeCoachApiClient());

      final response = await service.sendMessage('How is my form?');
      expect(response['status'], 'SAFE');
      expect(response['response'], contains('push through your heels'));

      final history = await service.getHistory();
      expect(history.length, 1);
      expect(history.first['message'], contains('squat depth'));
    });
  });

  group('AI Coach Screen & Form Analysis Widget Tests', () {
    testWidgets('AiCoachScreen renders input field, suggestions and coach headers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AiCoachScreen()));
      await tester.pumpAndSettle();

      expect(find.text('AI Coach'), findsOneWidget);
      expect(find.text('Powered by Llama 3 & Groq'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('LiveFormAnalysisScreen renders camera HUD, reps badge and summary', (
      WidgetTester tester,
    ) async {
      final testExercise = WorkoutPlanState.today.exercises.first;
      await tester.pumpWidget(
        MaterialApp(home: LiveFormAnalysisScreen(exercise: testExercise)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(testExercise.name), findsOneWidget);
      expect(find.text('REPS'), findsOneWidget);
      expect(find.text('Finish Form Analysis'), findsOneWidget);

      // Open set summary
      await tester.tap(find.text('Finish Form Analysis'));
      await tester.pumpAndSettle();

      expect(find.text('Form Analysis Summary'), findsOneWidget);
      expect(find.text('Form Score'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
