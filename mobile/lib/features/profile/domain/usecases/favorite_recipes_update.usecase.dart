import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/profile/data/dto/favorite_recipes_update.dto.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

class FavoriteRecipesUpdateUsecase implements UseCaseWithParams<Recipe?, FavoriteRecipesUpdateDto> {
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
