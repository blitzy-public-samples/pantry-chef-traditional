import 'package:camera/camera.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/api/ingredient.api.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Concrete data-layer repository for the ingredient feature.
///
/// Fulfills the domain [IngredientRepository] contract and adapts the
/// ingredient use cases to the remote [IngredientApi]. Stateless: each
/// method instantiates a fresh [IngredientApi] locally, delegates the
/// remote call, then maps the raw JSON into domain models.
class IngredientRepositoryImpl implements IngredientRepository {
  /// Loads ingredient reference data (categories and units).
  ///
  /// Requests [IngredientApi.getCategoriesAndUnits], maps
  /// `response['categories']` via [Category.fromJson] and
  /// `response['units']` via [Unit.fromJson], then returns them in an
  /// [IngredientAddData] aggregate.
  @override
  Future<IngredientAddData> getCategoriesAndUnits() async {
    // Fresh stateless API client instantiated per call.
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.getCategoriesAndUnits();
    List<dynamic> categories = response['categories'];
    List<dynamic> units = response['units'];
    return IngredientAddData(
      categories: categories.map((el) => Category.fromJson(el)).toList(),
      units: units.map((el) => Unit.fromJson(el)).toList(),
    );
  }

  /// Searches ingredients matching the [dto] criteria.
  ///
  /// Forwards [dto] (query, page, limit, sort) to
  /// [IngredientApi.searchIngredient] and maps the returned JSON list
  /// into a typed `List<Ingredient>` via [Ingredient.fromJson].
  @override
  Future<List<Ingredient>> searchIngredient(SearchDto dto) async {
    IngredientApi api = IngredientApi();
    List<dynamic> response = await api.searchIngredient(dto);
    return response.map((el) => Ingredient.fromJson(el)).toList();
  }

  // KNOWN ISSUE: method name `createingredient` is intentionally
  // lowercase (not `createIngredient`); preserved as a stable
  // identifier - document, never rename.
  /// Creates a new ingredient from the [dto] payload.
  ///
  /// Delegates to `IngredientApi.createIngredient` (camelCase API
  /// method) and maps the returned JSON map into a single [Ingredient]
  /// via [Ingredient.fromJson].
  @override
  Future<Ingredient> createingredient(CreateIngredientDto dto) async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.createIngredient(dto);
    return Ingredient.fromJson(response);
  }

  /// Extracts an ingredient from the captured/selected [image].
  ///
  /// Sends [image] to [IngredientApi.processImage] (backend AI vision)
  /// and maps the parsed response into an [Ingredient] via
  /// [Ingredient.fromJson].
  @override
  Future<Ingredient> processImage(XFile image) async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.processImage(image);
    return Ingredient.fromJson(response);
  }
}
