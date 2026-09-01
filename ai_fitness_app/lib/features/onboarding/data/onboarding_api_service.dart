import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';
import '../presentation/onboarding_state.dart';

class OnboardingApiService {
  final ApiClient _apiClient;

  OnboardingApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> completeOnboarding({
    String? token,
  }) async {
    final authToken = token ?? AuthSessionStore.token;

    final ageInt = int.tryParse(
      OnboardingData.age.replaceAll(RegExp(r'[^\d]'), ''),
    );
    final heightInt = int.tryParse(
      OnboardingData.height.replaceAll(RegExp(r'[^\d]'), ''),
    );
    final weightInt = int.tryParse(
      OnboardingData.weight.replaceAll(RegExp(r'[^\d]'), ''),
    );

    final payload = <String, dynamic>{
      'name': OnboardingData.name,
      'age': ageInt ?? 25,
      'gender': OnboardingData.gender,
      'heightCm': heightInt ?? 175,
      'weightKg': weightInt ?? 70,
      'fitnessGoal': OnboardingData.goal,
      'fitnessLevel': OnboardingData.fitnessLevel,
      'equipment': OnboardingData.equipment.toList(),
      'foods': OnboardingData.foods.toList(),
      'otherFood': OnboardingData.otherFood,
      'budget': OnboardingData.budget,
      'customBudget': OnboardingData.customBudget,
      'workoutFrequency': OnboardingData.workoutFrequency,
      'preferredDuration': OnboardingData.preferredDuration,
      'customDuration': OnboardingData.customDuration,
      'healthConditions': '',
    };

    final response = await _apiClient.post(
      '/api/v1/onboarding/complete',
      body: payload,
      token: authToken,
    );

    AuthSessionStore.markOnboardingComplete();
    return response['data'] as Map<String, dynamic>? ?? {};
  }
}

