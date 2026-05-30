/// Non-instantiable static namespace for global UI values shared consistently
/// across the PantryChef Flutter app.
///
/// The private `_()` constructor enforces non-instantiability; callers reference
/// members via `CommonConstants.appName`, `CommonConstants.pagePadding`, etc.
class CommonConstants {
  CommonConstants._();

  /// User-facing application name shown in app bars, the splash screen, and the
  /// platform manifest. Title-case branding string.
  static const String appName = 'PantryChef';
  /// Default horizontal and vertical padding applied to screen-level containers,
  /// in logical pixels.
  static const double pagePadding = 16.0;
  /// Height in logical pixels of the custom home-screen app bar.
  static const double homeAppBarHeight = 24;
  /// Scroll-position threshold in logical pixels from the bottom of the viewport
  /// at which infinite-scroll lists trigger the next-page fetch. Smaller values
  /// trigger fetches closer to the very bottom; larger values trigger earlier
  /// (better perceived performance at the cost of more eager network requests).
  static const double fetchScrollOffset = 150;
}
