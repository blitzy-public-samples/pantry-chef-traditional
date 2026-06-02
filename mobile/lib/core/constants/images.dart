/// Non-instantiable static namespace that centralizes image asset paths so
/// the app references images from a single source of truth.
///
/// The private constructor `Images._()` prevents instantiation.
///
class Images {
  // Private constructor: prevents instantiation of this static namespace.
  Images._();

  /// App logo image asset path `'assets/images/logo.png'`.
  static const String logo = 'assets/images/logo.png';
  /// Empty-pantry illustration asset path
  /// `'assets/images/empty_pantry.webp'` (a WebP-format image).
  static const String emptyPantry = 'assets/images/empty_pantry.webp';
}
