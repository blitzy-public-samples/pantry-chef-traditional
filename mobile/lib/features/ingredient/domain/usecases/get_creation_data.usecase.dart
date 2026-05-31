import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case that loads the categories and units the
/// add-ingredient form needs, as an [IngredientAddData].
///
/// Implements [UseCase] (no params); callers invoke it via `call`.
/// Source: core/utils/usercase.dart:L1
class GetIngredientCategoriesAndUnitsUsecase implements UseCase<IngredientAddData> {
  /// Returns the available categories and units as an
  /// [IngredientAddData]; takes no parameters.
  @override
  Future<IngredientAddData> call() {
    // Resolve the concrete repository behind the IngredientRepository
    // contract (stateless; a fresh impl per call).
    IngredientRepository repo = IngredientRepositoryImpl();
    // Delegate to the repository's getCategoriesAndUnits query.
    return repo.getCategoriesAndUnits();
  }
}
