/// A non-instantiable static namespace of global UI and layout values
/// shared across screens for consistent presentation.
///
/// The private constructor `CommonConstants._()` prevents instantiation;
/// all members are accessed statically.
///
class CommonConstants {
  // Private constructor: prevents instantiation of this static namespace.
  CommonConstants._();

  /// The application name, `'PantryChef'`.
  static const String appName = 'PantryChef';
  /// Default page padding in logical pixels (`16.0`).
  static const double pagePadding = 16.0;
  /// Home app-bar height in logical pixels (`24`, a double).
  static const double homeAppBarHeight = 24;
  /// Scroll offset in logical pixels (`150`, a double) that triggers
  /// content fetching (e.g. pagination / infinite scroll).
  static const double fetchScrollOffset = 150;
}
