import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';

class ProgressApiService {
  final ApiClient _apiClient;

  ProgressApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getSummary() async {
    final response = await _apiClient.get(
      '/api/v1/progress/summary',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to load progress summary',
    );
  }

  Future<Map<String, dynamic>> logWeight({
    required double weightKg,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'weightKg': weightKg,
      'notes': ?notes,
    };
    final response = await _apiClient.post(
      '/api/v1/progress/log-weight',
      body: body,
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to log weight',
    );
  }

  Future<List<Map<String, dynamic>>> getWeightHistory() async {
    final response = await _apiClient.get(
      '/api/v1/progress/weight-history',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
