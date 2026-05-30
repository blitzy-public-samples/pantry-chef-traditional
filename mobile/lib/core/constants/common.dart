class CommonConstants {
  CommonConstants._();

  static const String appName = 'PantryChef';
  static const double pagePadding = 16.0;
  static const double homeAppBarHeight = 24;
  static const double fetchScrollOffset = 150;

  // Added for "What Can I Make Tonight?" suggestions feature: a shared
  // spacing scale and component-dimension tokens so the new suggestions UI
  // (suggestions_screen.dart, suggestion_card.dart) resolves every layout
  // value to a design-system constant instead of using local magic numbers.
  // Spacing scale (logical pixels) for vertical/horizontal gaps and padding.
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  // Component dimension tokens.
  static const double cardImageHeight = 150.0;
  static const double progressBarMinHeight = 10.0;
  static const double emptyStateImageWidth = 200.0;
}
