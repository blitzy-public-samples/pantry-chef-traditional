import 'package:pantry_chef/core/constants/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  final SharedPreferences _sharedPreference;

  SharedPreferencesHelper(this._sharedPreference);

  String? get accessToken =>
      _sharedPreference.getString(Preferences.accessToken);

  Future<bool> saveAccessToken(String accessToken) =>
      _sharedPreference.setString(Preferences.accessToken, accessToken);

  String? get refreshToken =>
      _sharedPreference.getString(Preferences.refreshToken);

  Future<bool> saveRefreshToken(String refreshToken) =>
      _sharedPreference.setString(Preferences.refreshToken, refreshToken);

  Future<bool> removeAccessToken() =>
      _sharedPreference.remove(Preferences.accessToken);

  Future<bool> removeRefreshToken() =>
      _sharedPreference.remove(Preferences.refreshToken);
}
