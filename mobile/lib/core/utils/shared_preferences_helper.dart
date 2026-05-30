import 'package:pantry_chef/core/constants/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper around [SharedPreferences] for the app's authentication
/// tokens (access JWT and refresh JWT).
///
/// All keys are sourced from the `Preferences.*` constants in
/// `mobile/lib/core/constants/preferences.dart`, so callers cannot
/// accidentally use a wrong key string. Typically resolved via GetIt with
/// `getIt<SharedPreferencesHelper>()` (registered in
/// `mobile/lib/core/utils/service_locator.dart:L11-L12`).
///
/// Each token has a getter, a setter, and a remover; this is the single
/// entry point for JWT token storage across the app.
class SharedPreferencesHelper {
  final SharedPreferences _sharedPreference;

  /// Constructs the helper around an existing [SharedPreferences] instance.
  ///
  /// Typically invoked from `setupLocator()` after the asynchronous
  /// `SharedPreferences.getInstance()` future resolves; the instance is held
  /// as a private final field used by every getter, setter, and remover.
  SharedPreferencesHelper(this._sharedPreference);

  /// Returns the persisted access JWT, or `null` if the user is not logged in
  /// (no token saved, or it was cleared on logout).
  ///
  /// Reads the `Preferences.accessToken` key. Invoked by the `DioClient`
  /// request interceptor on every outbound API call to attach the
  /// `Authorization: Bearer <token>` header.
  String? get accessToken =>
      _sharedPreference.getString(Preferences.accessToken);

  /// Persists the access JWT under the `Preferences.accessToken` key.
  ///
  /// Returns a `Future<bool>` that resolves to `true` when the underlying
  /// [SharedPreferences.setString] write succeeds. Invoked from the login
  /// response handler and from `DioClient._refreshToken` after a successful
  /// token refresh.
  Future<bool> saveAccessToken(String accessToken) =>
      _sharedPreference.setString(Preferences.accessToken, accessToken);

  /// Returns the persisted refresh JWT, or `null` if absent.
  ///
  /// Reads the `Preferences.refreshToken` key. Used by
  /// `DioClient._refreshToken` to obtain a new access + refresh token pair
  /// when the access token expires (HTTP 401 or 419 responses).
  String? get refreshToken =>
      _sharedPreference.getString(Preferences.refreshToken);

  /// Persists the refresh JWT under the `Preferences.refreshToken` key.
  ///
  /// Returns a `Future<bool>` that resolves to `true` when the underlying
  /// [SharedPreferences.setString] write succeeds. The backend rotates
  /// refresh tokens, so this runs after every successful refresh.
  Future<bool> saveRefreshToken(String refreshToken) =>
      _sharedPreference.setString(Preferences.refreshToken, refreshToken);

  /// Removes the access JWT from [SharedPreferences].
  ///
  /// Used on logout and on unrecoverable session-expiration paths.
  Future<bool> removeAccessToken() =>
      _sharedPreference.remove(Preferences.accessToken);

  /// Removes the refresh JWT from [SharedPreferences].
  ///
  /// Used on logout, alongside [removeAccessToken], to fully clear the
  /// stored session.
  Future<bool> removeRefreshToken() =>
      _sharedPreference.remove(Preferences.refreshToken);
}
