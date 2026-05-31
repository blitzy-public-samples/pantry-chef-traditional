import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case that fetches the reference data (ingredient categories and
/// measurement units) used to populate the ingredient-creation form dropdowns.
///
/// Implements [UseCase]`<IngredientAddData>` — the parameterless variant of the
/// use-case contract from `package:pantry_chef/core/utils/usercase.dart` (the
/// `usercase` file name carries a verbatim-preserved typo and must not be
/// renamed). Sibling ingredient use cases implement the `UseCaseWithParams`
/// variant instead; this is the only one in the folder taking no parameters.
///
/// Resolves to an [IngredientAddData] wrapping `List<Category>` and
/// `List<Unit>`. Both lists are currently hardcoded server-side in
/// `backend/src/ingridient/ingridient.controller.ts:L41-L72` (5 categories:
/// spice, vegetable, fruit, dairy, protein; 9 units: kg, g, lb, oz, ml, l,
/// cup, tbsp, tsp). The backend `Ingridient` spelling (controller file and
/// module name) is preserved verbatim; the mobile layer uses the correct
/// `Ingredient` spelling even though the data originates from those server
/// `Ingridient*` artifacts.
///
/// Constructs a fresh [IngredientRepositoryImpl] on every call (no dependency
/// injection, no caching), matching the convention across all sibling use cases.
class GetIngredientCategoriesAndUnitsUsecase implements UseCase<IngredientAddData> {
  /// Fetches the categories and units reference data in a single round trip.
  ///
  /// Takes no parameters (parameterless [UseCase] variant) and returns a
  /// [Future] resolving to an [IngredientAddData] aggregate that holds
  /// `List<Category>` and `List<Unit>`.
  ///
  /// Delegates to [IngredientRepository.getCategoriesAndUnits] through a
  /// per-call [IngredientRepositoryImpl]; the concrete implementation issues
  /// `GET /api/v1/ingredient/creation-data` (the URL keeps the correct
  /// `ingredient` spelling even though the backend source spells it
  /// `Ingridient`). The returned categories and units are hardcoded
  /// server-side — see `backend/src/ingridient/ingridient.controller.ts:L41-L72`.
  @override
  Future<IngredientAddData> call() {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.getCategoriesAndUnits();
  }
}
