import 'package:json_annotation/json_annotation.dart';

part 'recipe_filters.dto.g.dart';

/// DTO for the backend's `/api/v1/recipe/matches` endpoint filter set.
///
/// The backend's `FilterType` post-filter step reads exactly these two
/// flags (see [ARCHITECTURE.md](../../../../../../ARCHITECTURE.md)
/// § Recipe Matching Pipeline).
@JsonSerializable()
class RecipeFiltersDto {
  /// When `true`, retains only recipes whose `totalIngredients <= 5`
  /// (server-side derivation). Defaults to `false`.
  final bool isQuickMake;
  /// When `true`, retains only recipes where the user is missing exactly
  /// 1 or 2 ingredients (server-side derivation). Defaults to `false`.
  final bool isAlmostThere;

  /// Creates a `RecipeFiltersDto`; both flags default to `false`, returning
  /// all matches when no filtering is requested.
  const RecipeFiltersDto({
    this.isQuickMake = false,
    this.isAlmostThere = false,
  });

  /// Serializes to the canonical JSON shape; passed as `queryParameters` to
  /// Dio at `RecipeApi.recipeMatching`.
  Map<String, dynamic> toJson() => _$RecipeFiltersDtoToJson(this);
}
