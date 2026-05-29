import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api');

  // SECURITY(SEC-C3): Release-mode builds MUST supply an HTTPS URL via
  // --dart-define API_BASE_URL=https://api.example.com/api
  // Debug/profile builds continue to use the HTTP default for local development.
  static void validate() {
    if (kReleaseMode && !apiBaseUrl.startsWith('https://')) {
      throw StateError(
        'Production builds must supply an HTTPS URL via --dart-define API_BASE_URL=https://... (SEC-C3)',
      );
    }
  }
}
