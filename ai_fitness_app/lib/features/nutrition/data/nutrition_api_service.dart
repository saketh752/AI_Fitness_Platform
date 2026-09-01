import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';

class NutritionApiService {
  final ApiClient _apiClient;

  NutritionApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getTodaySummary() async {
    final response = await _apiClient.get(
      '/api/v1/nutrition/today',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to load nutrition summary',
    );
  }

  Future<Map<String, dynamic>> logMeal({
    required String name,
    required String mealType,
    required int calories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/nutrition/log-meal',
      body: {
        'name': name,
        'mealType': mealType,
        'calories': calories,
        'proteinGrams': proteinGrams ?? 0,
        'carbsGrams': carbsGrams ?? 0,
        'fatGrams': fatGrams ?? 0,
      },
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to log meal',
    );
  }

  Future<void> deleteMeal(int mealId) async {
    final response = await _apiClient.delete(
      '/api/v1/nutrition/meals/$mealId',
      token: AuthSessionStore.token,
    );

    if (response['success'] != true) {
      throw ApiException(
        response['message']?.toString() ?? 'Failed to delete meal',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final response = await _apiClient.get(
      '/api/v1/nutrition/meals',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}

