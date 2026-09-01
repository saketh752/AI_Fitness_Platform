import '../../../core/network/api_client.dart';
import '../domain/auth_session_store.dart';
import '../presentation/mock_auth_state.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/signup',
      body: {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final token = data['token'] as String? ?? '';
    final userId = data['userId']?.toString();
    final name = data['name'] as String? ?? fullName.trim();
    final onboardingComplete = data['onboardingComplete'] == true;

    AuthSessionStore.saveSession(
      email: email.trim(),
      name: name,
      token: token,
      userId: userId,
      onboardingComplete: onboardingComplete,
      resumeRoute: '/onboarding/introduction',
    );

    MockAuthState.register(
      email: email.trim(),
      password: password,
      name: name,
    );

    // Ensure session preserves the real JWT token
    if (token.isNotEmpty) {
      AuthSessionStore.saveSession(
        email: email.trim(),
        name: name,
        token: token,
        userId: userId,
        onboardingComplete: onboardingComplete,
        resumeRoute: '/onboarding/introduction',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final token = data['token'] as String? ?? '';
    final userId = data['userId']?.toString();
    final name = data['name'] as String? ?? '';
    final onboardingComplete = data['onboardingComplete'] == true;

    AuthSessionStore.saveSession(
      email: email.trim(),
      name: name.isNotEmpty ? name : 'Alex',
      token: token,
      userId: userId,
      onboardingComplete: onboardingComplete,
      resumeRoute: onboardingComplete ? '/home' : MockAuthState.onboardingRoute,
    );

    MockAuthState.login(
      email: email.trim(),
      password: password,
    );

    if (token.isNotEmpty) {
      AuthSessionStore.saveSession(
        email: email.trim(),
        name: name.isNotEmpty ? name : 'Alex',
        token: token,
        userId: userId,
        onboardingComplete: onboardingComplete,
        resumeRoute: onboardingComplete ? '/home' : MockAuthState.onboardingRoute,
      );
    }

    return data;
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post(
      '/api/v1/auth/forgot-password',
      body: {'email': email.trim()},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/api/v1/auth/reset-password',
      body: {
        'token': token.trim(),
        'newPassword': newPassword,
      },
    );
  }
}
