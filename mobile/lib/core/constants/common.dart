/// A non-instantiable static namespace of global UI and layout values
/// shared across screens for consistent presentation.
///
/// The private constructor `CommonConstants._()` prevents instantiation;
/// all members are accessed statically.
///
/// Source: mobile/lib/core/constants/common.dart:L1-L2
class CommonConstants {
  // Private constructor: prevents instantiation of this static namespace.
  CommonConstants._();

  /// The application name, `'PantryChef'`.
  /// Source: mobile/lib/core/constants/common.dart:L4
  static const String appName = 'PantryChef';
  /// Default page padding in logical pixels (`16.0`).
  /// Source: mobile/lib/core/constants/common.dart:L5
  static const double pagePadding = 16.0;
  /// Home app-bar height in logical pixels (`24`, a double).
  /// Source: mobile/lib/core/constants/common.dart:L6
  static const double homeAppBarHeight = 24;
  /// Scroll offset in logical pixels (`150`, a double) that triggers
  /// content fetching (e.g. pagination / infinite scroll).
  /// Source: mobile/lib/core/constants/common.dart:L7
  static const double fetchScrollOffset = 150;
}
