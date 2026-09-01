import 'dart:convert';
import 'package:ai_fitness_app/app/app.dart';
import 'package:ai_fitness_app/core/network/api_client.dart';
import 'package:ai_fitness_app/features/auth/data/auth_api_service.dart';
import 'package:ai_fitness_app/features/auth/domain/auth_session_store.dart';
import 'package:ai_fitness_app/features/onboarding/data/onboarding_api_service.dart';
import 'package:ai_fitness_app/features/onboarding/presentation/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    AuthSessionStore.clearSession();
    OnboardingData.reset();
  });

  group('AuthSessionStore & Session Persistence', () {
    test('initially is not logged in', () {
      expect(AuthSessionStore.isLoggedIn, isFalse);
      expect(AuthSessionStore.token, isNull);
    });

    test('saveSession updates store and isLoggedIn is true', () {
      AuthSessionStore.saveSession(
        email: 'alex@example.com',
        name: 'Alex',
        token: 'test_token',
        onboardingComplete: true,
      );

      expect(AuthSessionStore.isLoggedIn, isTrue);
      expect(AuthSessionStore.email, 'alex@example.com');
      expect(AuthSessionStore.name, 'Alex');
      expect(AuthSessionStore.token, 'test_token');
      expect(AuthSessionStore.onboardingComplete, isTrue);
    });

    test('clearSession resets all session properties', () {
      AuthSessionStore.saveSession(
        email: 'alex@example.com',
        name: 'Alex',
        token: 'test_token',
        onboardingComplete: true,
      );

      AuthSessionStore.clearSession();

      expect(AuthSessionStore.isLoggedIn, isFalse);
      expect(AuthSessionStore.token, isNull);
      expect(AuthSessionStore.email, isEmpty);
    });
  });

  group('AuthApiService Integration Tests', () {
    test('signup posts to backend and stores token in session', () async {
      final mockHttpClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/signup');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'sarah@example.com');
        expect(body['fullName'], 'Sarah Connor');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'User registered successfully',
            'data': {
              'token': 'jwt_backend_token_123',
              'userId': 42,
              'name': 'Sarah Connor',
              'onboardingComplete': false,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttpClient);
      final authService = AuthApiService(apiClient: apiClient);

      final result = await authService.signup(
        fullName: 'Sarah Connor',
        email: 'sarah@example.com',
        password: 'Password123!',
      );

      expect(result['token'], 'jwt_backend_token_123');
      expect(result['userId'], 42);
      expect(AuthSessionStore.isLoggedIn, isTrue);
      expect(AuthSessionStore.email, 'sarah@example.com');
      expect(AuthSessionStore.name, 'Sarah Connor');
      expect(AuthSessionStore.token, 'jwt_backend_token_123');
      expect(AuthSessionStore.onboardingComplete, isFalse);
    });

    test('login posts credentials and loads user state', () async {
      final mockHttpClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'alex@example.com');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login successful',
            'data': {
              'token': 'jwt_login_token_999',
              'userId': 1,
              'name': 'Alex',
              'onboardingComplete': true,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttpClient);
      final authService = AuthApiService(apiClient: apiClient);

      final result = await authService.login(
        email: 'alex@example.com',
        password: 'Password1',
      );

      expect(result['token'], 'jwt_login_token_999');
      expect(AuthSessionStore.isLoggedIn, isTrue);
      expect(AuthSessionStore.onboardingComplete, isTrue);
      expect(AuthSessionStore.token, 'jwt_login_token_999');
    });

    test('forgotPassword dispatches email request', () async {
      var called = false;
      final mockHttpClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/forgot-password');
        called = true;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'If an account exists with this email, a reset link has been sent.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttpClient);
      final authService = AuthApiService(apiClient: apiClient);

      await authService.forgotPassword(email: 'alex@example.com');
      expect(called, isTrue);
    });

    test('resetPassword submits new password with token', () async {
      var called = false;
      final mockHttpClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/reset-password');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['token'], 'valid_uuid_token');
        expect(body['newPassword'], 'NewSecret123!');
        called = true;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Password has been reset successfully',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttpClient);
      final authService = AuthApiService(apiClient: apiClient);

      await authService.resetPassword(
        token: 'valid_uuid_token',
        newPassword: 'NewSecret123!',
      );
      expect(called, isTrue);
    });
  });

  group('OnboardingApiService Integration Tests', () {
    test('completeOnboarding sends serialized payload with auth token', () async {
      AuthSessionStore.saveSession(
        email: 'alex@example.com',
        name: 'Alex',
        token: 'auth_jwt_token',
      );

      OnboardingData.name = 'Alex User';
      OnboardingData.age = '30';
      OnboardingData.height = '180 cm';
      OnboardingData.weight = '75 kg';
      OnboardingData.goal = 'Build Muscle';
      OnboardingData.equipment.add('Dumbbells');
      OnboardingData.foods.add('Eggs');

      final mockHttpClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/onboarding/complete');
        expect(request.headers['Authorization'], 'Bearer auth_jwt_token');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['name'], 'Alex User');
        expect(body['age'], 30);
        expect(body['heightCm'], 180);
        expect(body['weightKg'], 75);
        expect(body['fitnessGoal'], 'Build Muscle');
        expect(body['equipment'], contains('Dumbbells'));
        expect(body['foods'], contains('Eggs'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Onboarding complete',
            'data': {
              'riskAssessment': {
                'riskLevel': 'LOW',
                'recommendation': 'STANDARD_PROGRAMMING',
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttpClient);
      final onboardingService = OnboardingApiService(apiClient: apiClient);

      final result = await onboardingService.completeOnboarding();
      expect(result['riskAssessment']['riskLevel'], 'LOW');
      expect(AuthSessionStore.onboardingComplete, isTrue);
    });
  });

  group('Splash Auto-Login Routing', () {
    testWidgets('unauthenticated splash routes to WelcomeScreen', (
      WidgetTester tester,
    ) async {
      AuthSessionStore.clearSession();

      await tester.pumpWidget(const AiFitnessApp());
      expect(find.text('AI Fitness'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fitness that fits'), findsWidgets);
    });

    testWidgets('authenticated user with completed onboarding routes to Home', (
      WidgetTester tester,
    ) async {
      AuthSessionStore.saveSession(
        email: 'alex@example.com',
        name: 'Alex',
        token: 'test_token',
        onboardingComplete: true,
      );

      await tester.pumpWidget(const AiFitnessApp());
      expect(find.text('AI Fitness'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.textContaining('Alex'), findsWidgets);
    });
  });
}
