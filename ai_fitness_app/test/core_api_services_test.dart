import 'dart:convert';
import 'package:ai_fitness_app/core/network/api_client.dart';
import 'package:ai_fitness_app/features/auth/domain/auth_session_store.dart';
import 'package:ai_fitness_app/features/dashboard/data/dashboard_api_service.dart';
import 'package:ai_fitness_app/features/nutrition/data/nutrition_api_service.dart';
import 'package:ai_fitness_app/features/Progress/data/progress_api_service.dart';
import 'package:ai_fitness_app/features/profile/data/profile_api_service.dart';
import 'package:ai_fitness_app/features/workouts/data/workout_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    AuthSessionStore.clearSession();
    AuthSessionStore.saveSession(
      email: 'test@example.com',
      name: 'Test Athlete',
      token: 'jwt-mock-token-12345',
      userId: '1',
      onboardingComplete: true,
    );
  });

  group('DashboardApiService', () {
    test('getDashboardData parses successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/dashboard');
        expect(request.headers['Authorization'], 'Bearer jwt-mock-token-12345');
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Dashboard loaded',
            'data': {
              'userName': 'Test',
              'greeting': 'Good Morning',
              'currentWorkout': {'name': 'Full Body Strength'},
              'weeklyCompletion': {'completed': 3, 'target': 4, 'percentage': 0.75},
              'stats': {'caloriesBurned': '350 kcal', 'activeMinutes': '45 min', 'streak': '5 Days'},
            },
          }),
          200,
        );
      });

      final service = DashboardApiService(apiClient: ApiClient(client: mockClient));
      final data = await service.getDashboardData();
      expect(data['userName'], 'Test');
      expect(data['greeting'], 'Good Morning');
      expect(data['weeklyCompletion']['completed'], 3);
    });
  });

  group('NutritionApiService', () {
    test('getTodaySummary and logMeal succeed', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/nutrition/today') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'targetCalories': 2200,
                'consumedCalories': 650,
                'remainingCalories': 1550,
                'todayMeals': [
                  {'id': 1, 'name': 'Oatmeal & Berries', 'calories': 350, 'mealType': 'BREAKFAST'},
                ],
              },
            }),
            200,
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/nutrition/log-meal') {
          final body = jsonDecode(request.body);
          expect(body['name'], 'Grilled Salmon');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'id': 2, 'name': 'Grilled Salmon', 'calories': 450},
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = NutritionApiService(apiClient: ApiClient(client: mockClient));
      final summary = await service.getTodaySummary();
      expect(summary['targetCalories'], 2200);
      expect(summary['consumedCalories'], 650);

      final logged = await service.logMeal(name: 'Grilled Salmon', mealType: 'DINNER', calories: 450);
      expect(logged['name'], 'Grilled Salmon');
      expect(logged['id'], 2);
    });
  });

  group('ProgressApiService', () {
    test('getSummary and logWeight succeed', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/progress/summary') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'totalWorkoutsCompleted': 12,
                'currentStreak': 5,
                'totalCaloriesBurned': 3600,
              },
            }),
            200,
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/progress/log-weight') {
          final body = jsonDecode(request.body);
          expect(body['weightKg'], 75.5);
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'id': 10, 'weightKg': 75.5, 'logDate': '2026-09-01'},
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = ProgressApiService(apiClient: ApiClient(client: mockClient));
      final summary = await service.getSummary();
      expect(summary['totalWorkoutsCompleted'], 12);
      expect(summary['currentStreak'], 5);

      final weight = await service.logWeight(weightKg: 75.5);
      expect(weight['weightKg'], 75.5);
    });
  });

  group('ProfileApiService', () {
    test('getProfile and updateProfile succeed', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/profile') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'fullName': 'Test Athlete',
                'email': 'test@example.com',
                'currentWeightKg': 76.0,
                'fitnessGoal': 'Build Muscle',
              },
            }),
            200,
          );
        } else if (request.method == 'PUT' && request.url.path == '/api/v1/profile') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'fullName': 'Updated Athlete',
                'email': 'test@example.com',
                'currentWeightKg': 74.5,
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = ProfileApiService(apiClient: ApiClient(client: mockClient));
      final profile = await service.getProfile();
      expect(profile['fullName'], 'Test Athlete');

      final updated = await service.updateProfile(fullName: 'Updated Athlete', currentWeightKg: 74.5);
      expect(updated['fullName'], 'Updated Athlete');
      expect(AuthSessionStore.name, 'Updated Athlete');
    });
  });

  group('WorkoutApiService', () {
    test('getCurrentPlan and logCompletedWorkout succeed', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/recommendations/current') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'planName': 'Hypertrophy Phase 1',
                'daysPerWeek': 4,
                'exercises': [
                  {'name': 'Barbell Bench Press', 'sets': 4, 'reps': '8-10'},
                ],
              },
            }),
            200,
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/recommendations/log-workout') {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Workout logged successfully',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = WorkoutApiService(apiClient: ApiClient(client: mockClient));
      final plan = await service.getCurrentPlan();
      expect(plan['planName'], 'Hypertrophy Phase 1');
      expect(plan['exercises'].length, 1);

      final logged = await service.logCompletedWorkout(
        workoutName: 'Hypertrophy Phase 1',
        durationMinutes: 50,
        caloriesBurned: 400,
        exercisesCompleted: 6,
      );
      expect(logged, isNotNull);
    });
  });
}
