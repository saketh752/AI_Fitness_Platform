import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';

class WorkoutApiService {
  final ApiClient _apiClient;

  WorkoutApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getCurrentPlan() async {
    final response = await _apiClient.get(
      '/api/v1/recommendations/current',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to load workout plan',
    );
  }

  Future<Map<String, dynamic>> logCompletedWorkout({
    required String workoutName,
    required int durationMinutes,
    required int caloriesBurned,
    required int exercisesCompleted,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/recommendations/log-workout',
      body: {
        'workoutName': workoutName,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'exercisesCompleted': exercisesCompleted,
      },
      token: AuthSessionStore.token,
    );

    if (response['success'] == true) {
      if (response['data'] != null) {
        return Map<String, dynamic>.from(response['data'] as Map);
      }
      return response;
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to log workout session',
    );
  }
}

