import 'package:camera/camera.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/api/ingredient.api.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Concrete data-layer implementation of [IngredientRepository].
///
/// Bridges the domain contract to the remote backend by delegating every call
/// to an [IngredientApi] instance. The class is stateless and instantiates a
/// fresh [IngredientApi] inside each method body rather than caching one as a
/// field, which keeps the implementation easy to substitute in dependency
/// injection and trivial to mock in tests. JSON responses from the API layer
/// are decoded into typed domain models ([Category], [Unit], [Ingredient],
/// [IngredientAddData]) before being returned to use cases.
class IngredientRepositoryImpl implements IngredientRepository {
  /// Fetches the categories and units reference data used by the add-ingredient
  /// flow and packages the result into an [IngredientAddData] aggregate.
  ///
  /// Calls `IngredientApi.getCategoriesAndUnits()`, expects a JSON map with
  /// `categories` and `units` arrays, and maps each element through
  /// `Category.fromJson` / `Unit.fromJson`. Throws if the backend response is
  /// missing either key.
  @override
  Future<IngredientAddData> getCategoriesAndUnits() async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.getCategoriesAndUnits();
    List<dynamic> categories = response['categories'];
    List<dynamic> units = response['units'];
    return IngredientAddData(
      categories: categories.map((el) => Category.fromJson(el)).toList(),
      units: units.map((el) => Unit.fromJson(el)).toList(),
    );
  }

  /// Performs a paginated ingredient search and maps the response array to a
  /// `List<Ingredient>`.
  ///
  /// Delegates to `IngredientApi.searchIngredient(dto)` and maps each element
  /// of the returned list through `Ingredient.fromJson`. Pagination parameters
  /// are carried inside [dto].
  @override
  Future<List<Ingredient>> searchIngredient(SearchDto dto) async {
    IngredientApi api = IngredientApi();
    List<dynamic> response = await api.searchIngredient(dto);
    return response.map((el) => Ingredient.fromJson(el)).toList();
  }

  /// Submits a new ingredient and returns the persisted domain model.
  ///
  /// Delegates to `IngredientApi.createIngredient(dto)` (the API-side method
  /// is `createIngredient` with an uppercase `I`) and maps the response map
  /// through `Ingredient.fromJson`. The method name on this class
  /// (`createingredient`, lowercase `i`) is preserved verbatim to match the
  /// signature declared on the abstract `IngredientRepository` contract at
  /// `domain/repositories/ingredient.repository.dart`.
  @override
  Future<Ingredient> createingredient(CreateIngredientDto dto) async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.createIngredient(dto);
    return Ingredient.fromJson(response);
  }

  /// Uploads a captured image to the backend AI vision endpoint and maps the
  /// resolved JSON into an [Ingredient].
  ///
  /// Delegates to `IngredientApi.processImage(image)` which posts a multipart
  /// upload to `/api/ai/vision`. When Google Cloud Vision returns no usable
  /// label the backend responds with an empty JSON object `{}`, in which case
  /// `Ingredient.fromJson({})` throws because required fields are absent. The
  /// upstream `CameraBloc` catches that error and emits `ImageProcessingError`,
  /// routing the user to manual entry.
  @override
  Future<Ingredient> processImage(XFile image) async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.processImage(image);
    return Ingredient.fromJson(response);
  }
}
