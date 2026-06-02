/// Non-instantiable static namespace centralizing icon asset paths so the
/// app references icons from a single source of truth.
///
/// The private constructor `IconsAsset._()` prevents instantiation.
///
class IconsAsset {
  // Private constructor: prevents instantiation of this static namespace.
  IconsAsset._();

  /// Icon asset path 'assets/icons/cross.png'.
  static const String cross = 'assets/icons/cross.png';
  /// Placeholder icon asset path 'assets/icons/no_image.png'.
  static const String noImage = 'assets/icons/no_image.png';
}
