/// Non-instantiable namespace of `SharedPreferences` storage-key strings.
///
/// Collects the string keys under which the app persists small pieces of state
/// in `shared_preferences`. These keys are read and written by
/// `mobile/lib/core/utils/shared_preferences_helper.dart` through the
/// `getString`, `setString`, and `remove` APIs; this class supplies only the
/// key names, never the stored values.
///
/// Disambiguation: this `Preferences` is the storage-key namespace and is
/// distinct from the user's dietary `Preferences` model at
/// `mobile/lib/features/profile/domain/models/preferences.dart` (the embedded
/// Preferences subdocument on the backend User schema). The two share a class
/// name but are told apart by import path:
///
/// - `package:pantry_chef/core/constants/preferences.dart` — this class
///   (SharedPreferences storage keys).
/// - `package:pantry_chef/features/profile/domain/models/preferences.dart` —
///   the user's profile/dietary model.
class Preferences {
  Preferences._();

  /// `SharedPreferences` key under which the JWT access token is persisted.
  ///
  /// Read via `SharedPreferencesHelper.accessToken` and written via
  /// `SharedPreferencesHelper.saveAccessToken`. The `DioClient` request
  /// interceptor reads this token and injects `Authorization: Bearer <token>`
  /// on every outbound request.
  static const String accessToken = "accessToken";
  /// `SharedPreferences` key under which the JWT refresh token is persisted.
  ///
  /// Read via `SharedPreferencesHelper.refreshToken` and written via
  /// `SharedPreferencesHelper.saveRefreshToken`. When the primary client gets a
  /// 401/419 response, `DioClient._refreshDio` sends this token to
  /// `Endpoints.refreshToken` to obtain a fresh access + refresh token pair.
  static const String refreshToken = "refreshToken";
  /// `SharedPreferences` key under which the user's selected locale code is
  /// persisted.
  ///
  /// Used by the localization layer to remember the user's language preference
  /// across app launches.
  static const String preferredLanguage = 'preferredLanguage';
}
