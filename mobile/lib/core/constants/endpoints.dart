import 'package:pantry_chef/env_config.dart';

class Endpoints {
  Endpoints._();

  // SECURITY(SEC-C3): Production builds MUST supply an HTTPS URL via
  // --dart-define API_BASE_URL=https://api.example.com/api
  // See mobile/lib/env_config.dart for runtime enforcement in release mode.
  static const String apiBaseUrl = EnvConfig.apiBaseUrl;
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration connectionTimeout = Duration(seconds: 30);

  // Auth
  static const String refreshToken = '$apiBaseUrl/auth/refresh';
  static const String login = '$apiBaseUrl/auth/email/login';
  static const String signup = '$apiBaseUrl/auth/email/register';
  static const String logout = '$apiBaseUrl/auth/logout';
  static const String profile = '$apiBaseUrl/auth/me';
  static const String updateProfile = '$apiBaseUrl/users';

  // Recipe
  static const String recipe = '$apiBaseUrl/recipe';

  // Ingredient
  static const String ingredient = '$apiBaseUrl/ingredient';
  static const String ingredientCreationData = '$ingredient/creation-data';

  // Pantry
  static const String pantry = '$apiBaseUrl/pantry';

  // AI
  static const String ai = '$apiBaseUrl/ai';
}
