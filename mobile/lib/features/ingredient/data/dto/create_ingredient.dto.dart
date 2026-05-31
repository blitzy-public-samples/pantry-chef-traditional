import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'create_ingredient.dto.g.dart';

/// Data transfer object sent in the body of `POST /api/v1/ingredient` to create
/// a new Ingridient (spelling preserved verbatim on the backend).
///
/// Serialized with `package:json_annotation`; the companion generated file
/// `create_ingredient.dto.g.dart` provides `_$CreateIngredientDtoToJson`.
/// Fields with custom mapping (`category`, `unit`) use `Mappers.categoryToJson`
/// and `Mappers.unitToJson` from `mobile/lib/core/utils/mappers.dart` so the
/// nested domain values are flattened into wire-format JSON expected by the
/// backend `IngridientService.create` handler.
@JsonSerializable()
class CreateIngredientDto {
  /// Human-readable name of the ingredient to create (e.g., `"tomato"`).
  final String name;
  /// Domain [Category] reference; serialized via `Mappers.categoryToJson` to
  /// the backend's `{ id, name }` reference shape.
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;
  /// Numeric quantity expressed in the chosen [unit]. Stored as a [double] so
  /// fractional values (e.g., `0.5` kg) are preserved.
  final double quantity;
  /// Domain [Unit] reference; serialized via `Mappers.unitToJson` to the
  /// backend's `{ id, name }` reference shape.
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;
  /// Optional image URL associated with the ingredient. May be `null` when the
  /// ingredient was created from a typed entry rather than a captured photo.
  final String? imageUrl;
  /// Optional expiration date as an ISO-8601 string. Stored as `String?` because
  /// the backend persists this field as a string; mobile callers serialize dates
  /// via the form before constructing the DTO.
  final String? expirationDate;
  /// Confidence score reported alongside the ingredient (1.0 = user-asserted,
  /// values below 1.0 indicate AI-inferred values). Defaults to `1`.
  final double confidence;

  /// Creates an immutable [CreateIngredientDto].
  ///
  /// `name`, `category`, `quantity`, and `unit` are required; `imageUrl` and
  /// `expirationDate` are optional and default to `null`; `confidence` defaults
  /// to `1`.
  const CreateIngredientDto({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    this.expirationDate,
    this.confidence = 1,
  });

  /// Serializes this DTO into a JSON-compatible map using the generated
  /// `_$CreateIngredientDtoToJson` helper.
  Map<String, dynamic> toJson() => _$CreateIngredientDtoToJson(this);
}
