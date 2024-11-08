import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

class GetFavoriteRecipeListUsecase implements UseCaseWithParams<List<Recipe>, List<String>> {
  @override
  Future<List<Recipe>> call(List<String> ids) async {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getFavoriteList(ids);
  }
}
