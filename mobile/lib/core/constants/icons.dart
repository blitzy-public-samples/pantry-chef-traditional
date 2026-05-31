/// Non-instantiable static namespace centralizing icon asset paths so the
/// app references icons from a single source of truth.
///
/// The private constructor `IconsAsset._()` prevents instantiation.
///
/// Source: mobile/lib/core/constants/icons.dart:L1-L2
class IconsAsset {
  // Private constructor: prevents instantiation of this static namespace.
  IconsAsset._();

  /// Icon asset path 'assets/icons/cross.png'.
  /// Source: mobile/lib/core/constants/icons.dart:L4
  static const String cross = 'assets/icons/cross.png';
  /// Placeholder icon asset path 'assets/icons/no_image.png'.
  /// Source: mobile/lib/core/constants/icons.dart:L5
  static const String noImage = 'assets/icons/no_image.png';
}
