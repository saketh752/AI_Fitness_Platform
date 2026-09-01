import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_session_store.dart';

class DashboardApiService {
  final ApiClient _apiClient;

  DashboardApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _apiClient.get(
      '/api/v1/dashboard',
      token: AuthSessionStore.token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw ApiException(
      response['message']?.toString() ?? 'Failed to load dashboard data',
    );
  }
}

