import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Default backend base URL.
  /// Can be overridden dynamically or via --dart-define=API_BASE_URL=...
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 is the Android emulator loopback to host localhost
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static String _apiBaseUrl = defaultBaseUrl;

  static String get apiBaseUrl => _apiBaseUrl;

  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
