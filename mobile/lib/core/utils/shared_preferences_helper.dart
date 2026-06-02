import 'package:pantry_chef/core/constants/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper over [SharedPreferences] for auth-token persistence.
/// Stores and reads tokens keyed by `Preferences.*` string constants.
/// Consumed by `dio_client.dart` and the authentication feature.
class SharedPreferencesHelper {
  // Private backing store; injected SharedPreferences instance.
  final SharedPreferences _sharedPreference;

  /// Creates the helper, storing the given [SharedPreferences]
  /// instance used for all token reads and writes.
  SharedPreferencesHelper(this._sharedPreference);

  /// Reads the stored access token from key
  /// `Preferences.accessToken`, or `null` if none is stored.
  String? get accessToken =>
      _sharedPreference.getString(Preferences.accessToken);

  /// Persists [accessToken] under key `Preferences.accessToken`.
  /// Completes with `true` when the write succeeds.
  Future<bool> saveAccessToken(String accessToken) =>
      _sharedPreference.setString(Preferences.accessToken, accessToken);

  /// Reads the stored refresh token from key
  /// `Preferences.refreshToken`, or `null` if none is stored.
  String? get refreshToken =>
      _sharedPreference.getString(Preferences.refreshToken);

  /// Persists [refreshToken] under key `Preferences.refreshToken`.
  /// Completes with `true` when the write succeeds.
  Future<bool> saveRefreshToken(String refreshToken) =>
      _sharedPreference.setString(Preferences.refreshToken, refreshToken);

  /// Deletes the stored access token from key
  /// `Preferences.accessToken`.
  Future<bool> removeAccessToken() =>
      _sharedPreference.remove(Preferences.accessToken);

  /// Deletes the stored refresh token from key
  /// `Preferences.refreshToken`.
  Future<bool> removeRefreshToken() =>
      _sharedPreference.remove(Preferences.refreshToken);
}
