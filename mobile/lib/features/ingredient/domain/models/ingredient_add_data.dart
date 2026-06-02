import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';

part 'ingredient_add_data.g.dart';

/// Immutable aggregate of the selectable reference data used to populate the
/// add-ingredient form: the available [Category] and [Unit] options.
///
/// Fetched from the backend `GET /api/ingredient/creation-data` endpoint and
/// modeled as a `@JsonSerializable()` value object deserialized from JSON.
///
/// Source:
/// mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L7-L10
@JsonSerializable()
class IngredientAddData {
  /// List of selectable ingredient [Category] options for the form.
  /// Source:
  /// mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L9
  final List<Category> categories;
  /// List of selectable measurement [Unit] options for the form.
  /// Source:
  /// mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L10
  final List<Unit> units;

  const IngredientAddData({
    required this.categories,
    required this.units,
  });

  // KNOWN ISSUE: this aggregate is deserialize-only; it defines no
  // `toJson`, unlike the bidirectional [Category] and [Unit] models.
  /// Builds an [IngredientAddData] from the decoded [json] map by delegating
  /// to the generated `_$IngredientAddDataFromJson` function.
  ///
  /// Source:
  /// mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L17
  factory IngredientAddData.fromJson(Map<String, dynamic> json) => _$IngredientAddDataFromJson(json);
}
