/// Non-instantiable static registry of named-route string constants.
///
/// Consumed by the app's route table and navigation helpers such as
/// `onGenerateRoute` and `Navigator.pushNamed`.
/// The private constructor `Navigation._()` prevents instantiation.
/// Source: mobile/lib/core/constants/navigation.dart:L1-L2
class Navigation {
  // Private constructor prevents instantiation of this static registry.
  Navigation._();

  /// Auth entry route.
  /// Source: mobile/lib/core/constants/navigation.dart:L4
  static const String authenticationStart = '/authenticationStart';
  /// Login route.
  /// Source: mobile/lib/core/constants/navigation.dart:L5
  static const String login = '/login';
  /// Signup route name. Intentionally misspelled (`singup`/`/singup`)
  /// and kept as a STABLE identifier referenced elsewhere; do NOT
  /// rename to `signup`/`/signup`.
  /// Source: mobile/lib/core/constants/navigation.dart:L6
  static const String singup = '/singup';
  /// Home route.
  /// Source: mobile/lib/core/constants/navigation.dart:L7
  static const String home = '/home';
  /// Recipe detail route.
  /// Source: mobile/lib/core/constants/navigation.dart:L8
  static const String recipeDetailed = '/recipeDetailed';
  /// AI/camera ingredient detection route.
  /// Source: mobile/lib/core/constants/navigation.dart:L9
  static const String ingredientDetecting = '/ingredientDetecting';
  /// Add-ingredient route.
  /// Source: mobile/lib/core/constants/navigation.dart:L10
  static const String ingredientAdding = '/ingredientAdding';
  /// Edit pantry item route.
  /// Source: mobile/lib/core/constants/navigation.dart:L11
  static const String pantryItemEdit = '/pantryItemEdit';
  /// Preferences route.
  /// Source: mobile/lib/core/constants/navigation.dart:L12
  static const String preferences = '/preferences';
  /// Favorite recipes route.
  /// Source: mobile/lib/core/constants/navigation.dart:L13
  static const String favoriteRecipes = '/favoriteRecipes';
}
