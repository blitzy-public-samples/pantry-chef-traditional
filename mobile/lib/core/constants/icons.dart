/// Non-instantiable static namespace of icon asset paths used across the app.
///
/// Each value is a path relative to the Flutter assets bundle, declared under
/// `flutter > assets` in `mobile/pubspec.yaml`. Unlike `Images`, which holds
/// larger illustrations and branding, this namespace collects small UI icons.
///
/// The class is intentionally named `IconsAsset` (not `Icons`) to avoid a naming
/// collision with Flutter Material's built-in `Icons` class (which exposes
/// `Icons.home`, `Icons.menu`, and similar). Do not rename it to `Icons`.
class IconsAsset {
  IconsAsset._();

  /// Asset path for the "X" close icon used by clear and dismiss controls, such
  /// as the clear button in the shared text field input and modal close buttons.
  static const String cross = 'assets/icons/cross.png';
  /// Asset path for the placeholder shown when a network image (for example a
  /// recipe or ingredient image) fails to load; rendered by the shared image widget.
  static const String noImage = 'assets/icons/no_image.png';
}
