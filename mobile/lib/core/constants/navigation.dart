/// Centralized registry of named-route constants for the app's navigation system.
///
/// `Navigation` is a non-instantiable static namespace — its only constructor is the
/// private `Navigation._()` — and every member is a `static const String` route name.
/// These constants are matched by `mobile/lib/core/navigation.dart`'s `onGenerateRoute`
/// callback, which resolves `RouteSettings.name` into concrete platform-adaptive
/// `PageRoute` instances via `platformPageRoute` from `flutter_platform_widgets`.
///
/// The `singup` route key preserves an intentional misspelling that must not be
/// corrected; see that constant's own documentation below.
class Navigation {
  Navigation._();

  /// Route name for the authentication landing screen.
  ///
  /// Also serves as the fallback route: `mobile/lib/core/navigation.dart`'s
  /// `onGenerateRoute` returns `AuthenticationStart()` from its `default` case
  /// when an unknown route name is requested.
  static const String authenticationStart = '/authenticationStart';
  /// Route name for the login screen. Resolved to `Login()` by `onGenerateRoute`.
  static const String login = '/login';
  // NOTE: 'singup' spelling preserved verbatim — stable route key, do not rename.
  /// Signup screen route name.
  ///
  /// Spelling `singup` (missing the second `g`) is intentional and preserved
  /// verbatim across the codebase; do not rename. Consumed by
  /// `authentication_start.dart` and resolved by `mobile/lib/core/navigation.dart`.
  static const String singup = '/singup';
  /// Route name for the home screen, the post-login landing destination.
  static const String home = '/home';
  /// Route name for the recipe detail screen (resolves to `RecipeDetailed()`).
  static const String recipeDetailed = '/recipeDetailed';
  /// Route name for the camera capture / AI label-detection flow.
  ///
  /// Resolves to `IngredientCameraDetecting()` in `onGenerateRoute`.
  static const String ingredientDetecting = '/ingredientDetecting';
  /// Route name for the ingredient-add form.
  ///
  /// Optionally pre-filled from a detected `Ingredient?` passed via
  /// `RouteSettings.arguments`; resolves to `IngredientAddingForm(...)`.
  static const String ingredientAdding = '/ingredientAdding';
  /// Route name for the pantry-item edit form.
  ///
  /// Takes a `PantryItem` argument via `RouteSettings.arguments`; resolves to
  /// `PantryItemEdit(...)`.
  static const String pantryItemEdit = '/pantryItemEdit';
  /// Route name for the user preferences screen.
  ///
  /// Covers dietary restrictions, allergies, disliked ingredients, and the
  /// maximum cooking time; resolves to `PreferencesScreen()`.
  static const String preferences = '/preferences';
  /// Route name for the user's saved-favorites screen (resolves to `FavoriteRecipes()`).
  static const String favoriteRecipes = '/favoriteRecipes';
}
