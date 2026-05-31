import 'package:pantry_chef/env_config.dart';

/// Non-instantiable static namespace for all backend HTTP API URLs and the Dio
/// timeout durations used across the PantryChef Flutter app.
///
/// [apiBaseUrl] is sourced from the compile-time [EnvConfig.apiBaseUrl], which reads
/// `--dart-define=API_BASE_URL=…` at compile time and defaults to
/// `http://192.168.2.20:3000/api`. Every endpoint URL below is constructed at compile
/// time via string interpolation against [apiBaseUrl].
///
/// See `mobile/lib/env_config.dart` for the compile-time base URL definition and
/// `mobile/lib/core/utils/dio_client.dart` for the HTTP client that consumes these URLs.
class Endpoints {
  Endpoints._();

  /// Root URL of the PantryChef backend.
  ///
  /// Resolved from [EnvConfig.apiBaseUrl], which reads `--dart-define=API_BASE_URL=…`
  /// at compile time. Defaults to the local network IP `http://192.168.2.20:3000/api`
  /// for development. For production builds, override via
  /// `flutter build … --dart-define=API_BASE_URL=https://api.pantry-chef.com/api`.
  static const String apiBaseUrl = EnvConfig.apiBaseUrl;
  /// Maximum time Dio waits for a response after the TCP connection is established
  /// (15 seconds). Applied uniformly to both the primary `dio` and `_refreshDio`
  /// instances in `DioClient`.
  static const Duration receiveTimeout = Duration(seconds: 15);
  /// Maximum time Dio waits to establish a TCP connection to the backend (30 seconds).
  ///
  /// Larger than [receiveTimeout] because cold-start latency on serverless / mobile
  /// networks can be high.
  static const Duration connectionTimeout = Duration(seconds: 30);

  // Auth
  /// Full URL of the token-refresh endpoint.
  ///
  /// Invoked by `DioClient._refreshDio` (in `mobile/lib/core/utils/dio_client.dart`)
  /// when the primary `dio` interceptor sees a 401 (`StatusCodes.unauthorized`) or
  /// 419 (`StatusCodes.tokenExpired`) response. Resolves to `<apiBaseUrl>/auth/refresh`
  /// (e.g. `/api/auth/refresh`). No `/v1` segment exists today: the backend applies only
  /// the global prefix `api` and never calls `app.enableVersioning()`.
  static const String refreshToken = '$apiBaseUrl/auth/refresh';
  /// Email-login endpoint (HTTP POST).
  ///
  /// Backend accepts `AuthEmailLoginDto { email, password }` and returns
  /// `{ token, refreshToken, tokenExpires, user }`.
  static const String login = '$apiBaseUrl/auth/email/login';
  /// Email-registration endpoint (HTTP POST). Backend path is `/auth/email/register`.
  ///
  /// This Dart constant uses the correct spelling `signup`, whereas the route key in
  /// `Navigation.singup` (spelling preserved verbatim) is a separate, intentionally
  /// misspelled identifier in another file. Do not conflate the two.
  static const String signup = '$apiBaseUrl/auth/email/register';
  /// Logout endpoint (HTTP POST).
  ///
  /// Invalidates the current session by setting `Session.deletedAt` on the backend.
  static const String logout = '$apiBaseUrl/auth/logout';
  /// Current-user profile endpoint (HTTP GET).
  ///
  /// Returns the authenticated user's `UserDto`.
  static const String profile = '$apiBaseUrl/auth/me';
  /// User-update endpoint (HTTP PATCH).
  ///
  /// Persists changes to the user's profile and embedded `Preferences` subdocument.
  static const String updateProfile = '$apiBaseUrl/users';

  // Recipe
  /// Recipe module root URL.
  ///
  /// Used as the base for `GET /recipe/matches`, `GET /recipe`, `GET /recipe/:id`,
  /// `POST /recipe`, `PATCH /recipe/:id`, and `DELETE /recipe/:id`.
  static const String recipe = '$apiBaseUrl/recipe';

  // Ingredient
  /// Ingredient module root URL.
  ///
  /// Note: the backend's filesystem directory is `backend/src/ingridient/` (spelling
  /// preserved verbatim throughout the backend codebase), but the backend Controller
  /// exposes the route at `/ingredient/*` (correctly spelled). This mobile constant
  /// therefore uses the correct spelling that matches the backend's external HTTP route.
  static const String ingredient = '$apiBaseUrl/ingredient';
  /// URL for fetching the category/unit reference data that populates the
  /// ingredient-creation forms.
  ///
  /// Returns a payload like `{ categories: Reference[], units: Reference[] }`.
  static const String ingredientCreationData = '$ingredient/creation-data';

  // Pantry
  /// Pantry module root URL.
  ///
  /// Used for `GET /pantry`, `POST /pantry`, `GET /pantry/:id`, `PATCH /pantry/:id`,
  /// and `DELETE /pantry/:id`.
  static const String pantry = '$apiBaseUrl/pantry';

  // AI
  /// AI vision module root URL.
  ///
  /// Used by the camera-detection flow for ingredient label detection via Google Cloud
  /// Vision (see the backend's `/ai/vision` endpoint and `mobile/lib/features/ingredient/`).
  static const String ai = '$apiBaseUrl/ai';
}
