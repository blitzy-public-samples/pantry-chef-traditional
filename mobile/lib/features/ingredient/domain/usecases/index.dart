// Barrel file for the ingredient feature's domain use cases.
//
// Re-exports the use cases in this directory so consumers can import them from
// a single path (`package:pantry_chef/features/ingredient/domain/usecases/index.dart`):
// [CreateIngredientUsecase], [GetIngredientCategoriesAndUnitsUsecase],
// [SearchIngredientUsecase], and [ImageProcessingUsecase].
//
// Note: the source file `search_ingredietn.usecase.dart` keeps the verbatim
// spelling `ingredietn` (transposed letters) as a stable file-system contract;
// the class it declares is correctly spelled [SearchIngredientUsecase].

export './create_ingredient.usecase.dart';
export './get_creation_data.usecase.dart';
export './search_ingredietn.usecase.dart';
export './image_processing.usecase.dart';
