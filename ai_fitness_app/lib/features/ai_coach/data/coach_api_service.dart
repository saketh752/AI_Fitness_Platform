import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';

class CoachApiService {
  final ApiClient _apiClient;

  CoachApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await _apiClient.post(
      '/api/v1/coach/chat',
      body: {'message': message.trim()},
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to get coach response',
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await _apiClient.get(
      '/api/v1/coach/history',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}

