import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/profile/data/dto/favorite_recipes_update.dto.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Application-layer entry point for toggling a recipe favorite — adding or
/// removing a recipe from the user's favorites list. Implements
/// [UseCaseWithParams]<`Recipe?`, [FavoriteRecipesUpdateDto]> (core
/// `usercase.dart`, filename typo preserved verbatim).
///
/// Cross-feature coupling: this is the ONLY usecase in the profile feature that
/// crosses into the recipe feature — it builds [RecipeRepositoryImpl] directly
/// alongside [ProfileRepositiryImpl] (typo preserved). It runs two steps: PATCH
/// the favorites list via [ProfileRepositiryImpl.updateFavoriteRecipesList],
/// then, only when `dto.addedId != null`, fetch the [Recipe] via
/// [RecipeRepositoryImpl.getRecipeById] so the BLoC can render it without an
/// extra round-trip. A null `dto.addedId` is a "remove favorite" op → `null`.
class FavoriteRecipesUpdateUsecase implements UseCaseWithParams<Recipe?, FavoriteRecipesUpdateDto> {
  /// Executes the use case: returns the newly-added [Recipe] when `dto.addedId`
  /// is non-null, otherwise returns `null` (the "remove favorite" path). First
  /// PATCHes the favorites list via [ProfileRepositiryImpl], then conditionally
  /// fetches the added [Recipe] via [RecipeRepositoryImpl]. Errors from either
  /// call (e.g. a `DioException`) propagate up uncaught — no handling occurs here.
  @override
  Future<Recipe?> call(FavoriteRecipesUpdateDto dto) async {
    ProfileRepository profileRepo = ProfileRepositiryImpl();
    await profileRepo.updateFavoriteRecipesList(dto.favoriteList);
    RecipeRepository recipeRepo = RecipeRepositoryImpl();
    Recipe? addedRecipe;
    if (dto.addedId != null) {
      addedRecipe = await recipeRepo.getRecipeById(dto.addedId!);
    }
    return addedRecipe;
  }
}
