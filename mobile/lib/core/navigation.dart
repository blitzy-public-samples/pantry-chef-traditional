import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/home.dart';
import 'package:pantry_chef/features/authentication/presentation/widgets/screens/authentication_start.dart';
import 'package:pantry_chef/features/authentication/presentation/widgets/screens/login.dart';
import 'package:pantry_chef/features/authentication/presentation/widgets/screens/signup.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/screens/ingredient_adding_form.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/screens/ingredient_camera_detecting.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/presentation/widgets/screens/pantry_item_edit.dart';
import 'package:pantry_chef/features/profile/presentation/widgets/screens/favorite_recipes.dart';
import 'package:pantry_chef/features/profile/presentation/widgets/screens/preferences.dart';
import 'package:pantry_chef/features/recipe/presentation/widgets/screens/recipe_detailed.dart';

Route<dynamic> onGenerateRoute(BuildContext context, RouteSettings settings) {
  T getArguments<T>() {
    return settings.arguments as T;
  }

  PageRoute<T> createPageRoute<T>({required WidgetBuilder builder}) {
    return platformPageRoute(context: context, builder: builder, settings: settings);
  }

  switch (settings.name) {
    case Navigation.login:
      return createPageRoute(builder: (_) => const Login());
    case Navigation.singup:
      return createPageRoute(builder: (_) => const Signup());
    case Navigation.home:
      return createPageRoute(builder: (_) => const Home());
    case Navigation.recipeDetailed:
      return createPageRoute(builder: (_) => const RecipeDetailed());
    case Navigation.ingredientDetecting:
      return createPageRoute(builder: (_) => const IngredientCameraDetecting());
    case Navigation.ingredientAdding:
      return createPageRoute(builder: (_) => IngredientAddingForm(detectedIngredient: getArguments<Ingredient?>()));
    case Navigation.pantryItemEdit:
      return createPageRoute(builder: (_) => PantryItemEdit(item: getArguments<PantryItem>()));
    case Navigation.preferences:
      return createPageRoute(builder: (_) => PreferencesScreen());
    case Navigation.favoriteRecipes:
      return createPageRoute(builder: (_) => FavoriteRecipes());
    default:
      return createPageRoute(builder: (_) => const AuthenticationStart());
  }
}
