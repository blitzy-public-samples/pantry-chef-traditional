/// `Preferences` is a non-instantiable static namespace of
/// `SharedPreferences` storage keys consumed by `SharedPreferencesHelper`
/// for persisting client-side state.
///
/// The private constructor `Preferences._()` prevents instantiation.
///
class Preferences {
  // Private constructor; prevents instantiation.
  Preferences._();

  /// SharedPreferences key `"accessToken"` for the persisted JWT access
  /// token.
  static const String accessToken = "accessToken";
  /// SharedPreferences key `"refreshToken"` for the persisted refresh
  /// token.
  static const String refreshToken = "refreshToken";
  /// SharedPreferences key `'preferredLanguage'` for the user's selected
  /// language.
  static const String preferredLanguage = 'preferredLanguage';
}
