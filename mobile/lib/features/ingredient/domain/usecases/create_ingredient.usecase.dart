import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case that creates an [Ingredient] from a
/// [CreateIngredientDto] supplied by the add-ingredient form.
///
/// Implements [UseCaseWithParams] so callers invoke it via `call`.
/// Source: core/utils/usercase.dart:L5
class CreateIngredientUsecase implements UseCaseWithParams<Ingredient, CreateIngredientDto> {
  /// Creates the ingredient described by [dto] and returns the saved
  /// [Ingredient].
  @override
  Future<Ingredient> call(CreateIngredientDto dto) {
    // Resolve the concrete repository behind the IngredientRepository
    // contract (stateless; a fresh impl per call).
    IngredientRepository repo = IngredientRepositoryImpl();
    // Delegate to repo.createingredient (lowercase name preserved).
    return repo.createingredient(dto);
  }
}
