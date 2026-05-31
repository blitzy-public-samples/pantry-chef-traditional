import 'package:pantry_chef/env_config.dart';

/// Non-instantiable static catalog of backend API URLs and request timeouts.
///
/// Consumed by the Dio client (`dio_client.dart`) and feature repositories.
/// The private constructor `Endpoints._()` prevents instantiation, so this
/// class serves purely as a namespace of `static const` values.
/// Source: mobile/lib/core/constants/endpoints.dart:L3-L4
class Endpoints {
  // Private constructor prevents instantiation of this static-only namespace.
  Endpoints._();

  /// Backend API base URL, re-exported from [EnvConfig.apiBaseUrl].
  ///
  /// Resolved at compile time via `String.fromEnvironment('API_BASE_URL')`,
  /// defaulting to `http://192.168.2.20:3000/api`. The base URL ALREADY
  /// includes the `/api` prefix, so every endpoint below resolves to
  /// `/api/<resource>` with NO `/v1/` segment.
  /// Source: mobile/lib/core/constants/endpoints.dart:L6,
  /// mobile/lib/env_config.dart:L2
  static const String apiBaseUrl = EnvConfig.apiBaseUrl;
  /// Response receive timeout for Dio requests, 15 seconds.
  /// Source: mobile/lib/core/constants/endpoints.dart:L7
  static const Duration receiveTimeout = Duration(seconds: 15);
  /// Connection timeout for Dio requests, 30 seconds.
  /// Source: mobile/lib/core/constants/endpoints.dart:L8
  static const Duration connectionTimeout = Duration(seconds: 30);

  // Auth
  /// Token refresh endpoint, resolving to `<apiBaseUrl>/auth/refresh`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L11
  static const String refreshToken = '$apiBaseUrl/auth/refresh';
  /// Email login endpoint, resolving to `<apiBaseUrl>/auth/email/login`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L12
  static const String login = '$apiBaseUrl/auth/email/login';
  /// Email registration endpoint, `<apiBaseUrl>/auth/email/register`.
  ///
  /// This constant is CORRECTLY spelled `signup`; do not confuse it with
  /// the misspelled `singup` ROUTE in navigation.dart. Both are kept as-is.
  /// Source: mobile/lib/core/constants/endpoints.dart:L13
  static const String signup = '$apiBaseUrl/auth/email/register';
  /// Logout endpoint, resolving to `<apiBaseUrl>/auth/logout`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L14
  static const String logout = '$apiBaseUrl/auth/logout';
  /// Current-user profile endpoint, resolving to `<apiBaseUrl>/auth/me`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L15
  static const String profile = '$apiBaseUrl/auth/me';
  /// Profile update endpoint, resolving to `<apiBaseUrl>/users`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L16
  static const String updateProfile = '$apiBaseUrl/users';

  // Recipe
  /// Recipe collection endpoint, resolving to `<apiBaseUrl>/recipe`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L19
  static const String recipe = '$apiBaseUrl/recipe';

  // Ingredient
  /// Ingredient collection endpoint, resolving to `<apiBaseUrl>/ingredient`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L22
  static const String ingredient = '$apiBaseUrl/ingredient';
  /// Ingredient creation-data endpoint, `<ingredient>/creation-data`
  /// (resolves to `<apiBaseUrl>/ingredient/creation-data`).
  /// Source: mobile/lib/core/constants/endpoints.dart:L23
  static const String ingredientCreationData = '$ingredient/creation-data';

  // Pantry
  /// Pantry collection endpoint, resolving to `<apiBaseUrl>/pantry`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L26
  static const String pantry = '$apiBaseUrl/pantry';

  // AI
  /// AI vision endpoint root, resolving to `<apiBaseUrl>/ai`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L29
  static const String ai = '$apiBaseUrl/ai';
}
