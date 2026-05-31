/// Non-instantiable static namespace that centralizes image asset paths so
/// the app references images from a single source of truth.
///
/// The private constructor `Images._()` prevents instantiation.
///
/// Source: mobile/lib/core/constants/images.dart:L1-L2
class Images {
  // Private constructor: prevents instantiation of this static namespace.
  Images._();

  /// App logo image asset path `'assets/images/logo.png'`.
  /// Source: mobile/lib/core/constants/images.dart:L4
  static const String logo = 'assets/images/logo.png';
  /// Empty-pantry illustration asset path
  /// `'assets/images/empty_pantry.webp'` (a WebP-format image).
  /// Source: mobile/lib/core/constants/images.dart:L5
  static const String emptyPantry = 'assets/images/empty_pantry.webp';
}
