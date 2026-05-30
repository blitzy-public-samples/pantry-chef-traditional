import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

class GetSuggestionsUsecase implements UseCaseWithParams<RecipeSuggestionsResponseDto, RecipeFiltersDto> {
  @override
  Future<RecipeSuggestionsResponseDto> call(RecipeFiltersDto filters) {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getSuggestions(filters);
  }
}
