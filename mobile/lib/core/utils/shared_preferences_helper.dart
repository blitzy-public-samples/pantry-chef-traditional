import 'package:pantry_chef/core/constants/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper over [SharedPreferences] for auth-token persistence.
/// Stores and reads tokens keyed by `Preferences.*` string constants.
/// Consumed by `dio_client.dart` and the authentication feature.
/// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L4
class SharedPreferencesHelper {
  // Private backing store; injected SharedPreferences instance.
  final SharedPreferences _sharedPreference;

  /// Creates the helper, storing the given [SharedPreferences]
  /// instance used for all token reads and writes.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L7
  SharedPreferencesHelper(this._sharedPreference);

  /// Reads the stored access token from key
  /// `Preferences.accessToken`, or `null` if none is stored.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L9-L10
  String? get accessToken =>
      _sharedPreference.getString(Preferences.accessToken);

  /// Persists [accessToken] under key `Preferences.accessToken`.
  /// Completes with `true` when the write succeeds.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L12-L13
  Future<bool> saveAccessToken(String accessToken) =>
      _sharedPreference.setString(Preferences.accessToken, accessToken);

  /// Reads the stored refresh token from key
  /// `Preferences.refreshToken`, or `null` if none is stored.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L15-L16
  String? get refreshToken =>
      _sharedPreference.getString(Preferences.refreshToken);

  /// Persists [refreshToken] under key `Preferences.refreshToken`.
  /// Completes with `true` when the write succeeds.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L18-L19
  Future<bool> saveRefreshToken(String refreshToken) =>
      _sharedPreference.setString(Preferences.refreshToken, refreshToken);

  /// Deletes the stored access token from key
  /// `Preferences.accessToken`.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L21-L22
  Future<bool> removeAccessToken() =>
      _sharedPreference.remove(Preferences.accessToken);

  /// Deletes the stored refresh token from key
  /// `Preferences.refreshToken`.
  /// Source: mobile/lib/core/utils/shared_preferences_helper.dart:L24-L25
  Future<bool> removeRefreshToken() =>
      _sharedPreference.remove(Preferences.refreshToken);
}
