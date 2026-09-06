import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Default backend base URL.
  /// Can be overridden dynamically or via --dart-define=API_BASE_URL=...
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Default to production Render cloud backend
    return 'https://ai-fitness-backend-0klk.onrender.com';
  }

  static String _apiBaseUrl = defaultBaseUrl;

  static String get apiBaseUrl => _apiBaseUrl;

  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
