import 'package:json_annotation/json_annotation.dart';

part 'recipe_filters.dto.g.dart';

/// Immutable, JSON-serializable filter DTO sent as query params to
/// the recipe `/matches` endpoint.
@JsonSerializable()
class RecipeFiltersDto {
  /// Quick-make filter flag (default `false`).
  final bool isQuickMake;
  /// Almost-there filter flag (default `false`).
  final bool isAlmostThere;

  const RecipeFiltersDto({
    this.isQuickMake = false,
    this.isAlmostThere = false,
  });

  /// Serializes via the generated `_$RecipeFiltersDtoToJson`.
  Map<String, dynamic> toJson() => _$RecipeFiltersDtoToJson(this);
}
