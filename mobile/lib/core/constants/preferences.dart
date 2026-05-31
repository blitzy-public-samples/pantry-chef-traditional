/// `Preferences` is a non-instantiable static namespace of
/// `SharedPreferences` storage keys consumed by `SharedPreferencesHelper`
/// for persisting client-side state.
///
/// The private constructor `Preferences._()` prevents instantiation.
///
/// Source: mobile/lib/core/constants/preferences.dart:L1-L2
class Preferences {
  // Private constructor; prevents instantiation.
  Preferences._();

  /// SharedPreferences key `"accessToken"` for the persisted JWT access
  /// token.
  /// Source: mobile/lib/core/constants/preferences.dart:L4
  static const String accessToken = "accessToken";
  /// SharedPreferences key `"refreshToken"` for the persisted refresh
  /// token.
  /// Source: mobile/lib/core/constants/preferences.dart:L5
  static const String refreshToken = "refreshToken";
  /// SharedPreferences key `'preferredLanguage'` for the user's selected
  /// language.
  /// Source: mobile/lib/core/constants/preferences.dart:L6
  static const String preferredLanguage = 'preferredLanguage';
}
