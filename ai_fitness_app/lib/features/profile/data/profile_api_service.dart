import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get(
      '/api/v1/profile',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to load profile',
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    int? age,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    String? fitnessGoal,
    String? activityLevel,
  }) async {
    final payload = <String, dynamic>{};
    if (fullName != null) payload['fullName'] = fullName;
    if (age != null) payload['age'] = age;
    if (gender != null) payload['gender'] = gender;
    if (heightCm != null) payload['heightCm'] = heightCm;
    if (currentWeightKg != null) payload['currentWeightKg'] = currentWeightKg;
    if (fitnessGoal != null) payload['fitnessGoal'] = fitnessGoal;
    if (activityLevel != null) payload['activityLevel'] = activityLevel;

    final response = await _apiClient.put(
      '/api/v1/profile',
      body: payload,
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      final data = Map<String, dynamic>.from(response['data'] as Map);
      if (fullName != null && fullName.isNotEmpty) {
        AuthSessionStore.saveSession(
          email: AuthSessionStore.email,
          name: fullName,
          token: AuthSessionStore.token,
          userId: AuthSessionStore.userId,
          onboardingComplete: AuthSessionStore.onboardingComplete,
        );
      }
      return data;
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to update profile',
    );
  }
}
