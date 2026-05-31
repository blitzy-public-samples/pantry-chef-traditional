import 'package:camera/camera.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';

/// Domain contract (abstraction) for the ingredient feature's data
/// access. Declares the operations the ingredient domain requires from
/// any concrete repository, decoupling domain and use-case logic from
/// the data sources (REST API, cache, local storage).
///
/// The concrete realization is `IngredientRepositoryImpl` in the data
/// layer. This is a pure interface: it has no fields and no constructor.
/// Source: features/ingredient/data/repositories/ingredient.repository.dart
abstract class IngredientRepository {
  /// Returns the [IngredientAddData] (available categories and units)
  /// used to populate the add-ingredient form. Takes no parameters.
  Future<IngredientAddData> getCategoriesAndUnits();

  /// Returns the ingredients matching the [dto] search criteria.
  ///
  /// [dto] carries the query, pagination (page/limit), and optional
  /// sort order. Source: core/data/dto/search.dto.dart:L8
  Future<List<Ingredient>> searchIngredient(SearchDto dto);

  // KNOWN ISSUE: the method name `createingredient` is intentionally all
  // lowercase (not camelCase `createIngredient`); it is a preserved,
  // stable identifier across callers/implementations. Document, never
  // rename.
  /// Creates and returns an [Ingredient] from the [dto] payload.
  ///
  /// [dto] supplies name, category, quantity, unit, optional image and
  /// expiry, plus a 0-1 confidence.
  /// Source: features/ingredient/data/dto/create_ingredient.dto.dart:L9
  Future<Ingredient> createingredient(CreateIngredientDto dto);

  /// Performs image-based ingredient inference from the captured [image].
  ///
  /// [image] is a `camera` package `XFile` (e.g. a device-camera photo).
  /// Returns the recognized [Ingredient].
  Future<Ingredient> processImage(XFile image);
}
