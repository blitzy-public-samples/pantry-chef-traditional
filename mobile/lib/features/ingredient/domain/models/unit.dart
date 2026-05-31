import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

/// Lightweight reference data model representing a unit of measurement.
///
/// Units are server-defined constants fetched via `GET /api/v1/ingredient/creation-data`
/// alongside categories. Currently 9 units are hardcoded server-side: `kg`, `g`, `lb`, `oz`,
/// `ml`, `l`, `cup`, `tbsp`, `tsp` (see `backend/src/ingridient/ingridient.controller.ts`).
///
/// The [id] field is an `int` (sequential 1–9) because units are hardcoded constants on the
/// backend, not persisted MongoDB documents — distinct from `Ingredient.id` which is a
/// MongoDB ObjectId hex string.
@JsonSerializable()
class Unit {
  /// Server-defined integer identifier (sequential 1–9: 1=kg, 2=g, 3=lb, etc.).
  final int id;

  /// Display name of the unit (e.g., "kg", "g", "tbsp", "tsp").
  final String name;

  /// Creates a [Unit] reference object.
  ///
  /// The constructor is `const` with two required named parameters: [id] and [name].
  const Unit({
    required this.id,
    required this.name,
  });

  /// Deserializes a [Unit] from a JSON map via the generated `_$UnitFromJson`
  /// (in `unit.g.dart`).
  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  /// Serializes this [Unit] to a JSON map via the generated `_$UnitToJson`
  /// (in `unit.g.dart`).
  ///
  /// Also consumed by `Mappers.unitToJson` for nested serialization in `Ingredient.unit`
  /// and `CreateIngredientDto.unit` (see `mobile/lib/core/utils/mappers.dart`).
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
