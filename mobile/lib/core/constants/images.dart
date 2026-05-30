/// Non-instantiable static namespace of image asset paths used across the app.
///
/// Each value is a path relative to the Flutter assets bundle, declared under
/// `flutter > assets` in `mobile/pubspec.yaml`. Unlike `IconsAsset`, which holds
/// small UI icons, `Images` collects larger illustrations, branding, and
/// placeholder graphics.
class Images {
  Images._();

  /// Asset path for the app logo, used by the splash screen, app bar branding,
  /// and the launcher icon.
  static const String logo = 'assets/images/logo.png';
  /// Asset path for the illustration shown when the user's pantry is empty
  /// (the empty-state graphic on the Pantry screen).
  static const String emptyPantry = 'assets/images/empty_pantry.webp';
}
