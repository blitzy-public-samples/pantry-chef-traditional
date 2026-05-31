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

  // NOTE: toJson() always emits both flags, so default false sends
  // isQuickMake=false&isAlmostThere=false on the wire.
  // FIXME: the backend reads these query params as STRINGS, and the non-empty string
  // "false" is truthy server-side, so both-false does NOT return all matches as one
  // might expect. Document only; do not fix (see README § Known Limitations).
  /// Creates a `RecipeFiltersDto`. Both flags default to `false`.
  ///
  /// Caveat: because the backend evaluates these query-string values truthily, sending
  /// both flags `false` does NOT behave as "no filter / return all matches"; see the
  /// boolean-filter contract note in
  /// `mobile/lib/features/recipe/README.md` § Known Limitations and Implementation Gaps.
  const RecipeFiltersDto({
    this.isQuickMake = false,
    this.isAlmostThere = false,
  });

  /// Serializes to the canonical JSON shape; passed as `queryParameters` to
  /// Dio at `RecipeApi.recipeMatching`.
  Map<String, dynamic> toJson() => _$RecipeFiltersDtoToJson(this);
}
