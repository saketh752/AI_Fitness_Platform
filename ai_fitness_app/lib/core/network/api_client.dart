import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  ApiException(this.message, {this.statusCode, this.errorData});

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 45);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = AppConfig.apiBaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$cleanPath').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final response = await _client
          .get(uri, headers: _buildHeaders(token: token))
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Unable to connect to the server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. The cloud server may be waking up—please try again.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Unable to connect to the server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. The cloud server may be waking up—please try again.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Unable to connect to the server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. The cloud server may be waking up—please try again.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .delete(uri, headers: _buildHeaders(token: token))
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Unable to connect to the server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. The cloud server may be waking up—please try again.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': response.body};
      }
      throw ApiException(
        'Server returned status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final success = jsonBody['success'] == true;
    final message = jsonBody['message'] as String? ?? '';

    if (!success || response.statusCode >= 400) {
      final errorMsg = message.isNotEmpty
          ? message
          : (jsonBody['error']?.toString() ?? 'Operation failed');
      throw ApiException(
        errorMsg,
        statusCode: response.statusCode,
        errorData: jsonBody['error'],
      );
    }

    return jsonBody;
  }
}
