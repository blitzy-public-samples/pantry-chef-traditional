/// Non-instantiable static registry of named-route string constants.
///
/// Consumed by the app's route table and navigation helpers such as
/// `onGenerateRoute` and `Navigator.pushNamed`.
/// The private constructor `Navigation._()` prevents instantiation.
class Navigation {
  // Private constructor prevents instantiation of this static registry.
  Navigation._();

  /// Auth entry route.
  static const String authenticationStart = '/authenticationStart';
  /// Login route.
  static const String login = '/login';
  /// Signup route name. Intentionally misspelled (`singup`/`/singup`)
  /// and kept as a STABLE identifier referenced elsewhere; do NOT
  /// rename to `signup`/`/signup`.
  static const String singup = '/singup';
  /// Home route.
  static const String home = '/home';
  /// Recipe detail route.
  static const String recipeDetailed = '/recipeDetailed';
  /// AI/camera ingredient detection route.
  static const String ingredientDetecting = '/ingredientDetecting';
  /// Add-ingredient route.
  static const String ingredientAdding = '/ingredientAdding';
  /// Edit pantry item route.
  static const String pantryItemEdit = '/pantryItemEdit';
  /// Preferences route.
  static const String preferences = '/preferences';
  /// Favorite recipes route.
  static const String favoriteRecipes = '/favoriteRecipes';
}
