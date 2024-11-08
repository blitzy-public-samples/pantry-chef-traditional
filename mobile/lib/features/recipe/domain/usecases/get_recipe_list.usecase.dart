import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

class GetRecipeListUsecase implements UseCase<List<Recipe>> {
  @override
  Future<List<Recipe>> call() {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getRecipeList();
  }
}
