import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/data/dto/order.dto.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'query_recipe.dto.g.dart';

/// DTO for general recipe queries: pagination, search, id lookup, and sort.
///
/// Used by `RecipeApi.getRecipeList` and `RecipeApi.getFavoriteList`. The
/// `limit` default of 500 is intentionally permissive; the backend silently
/// clamps it to 50 (see `mobile/lib/features/recipe/README.md`
/// § API / Endpoint Reference).
@JsonSerializable()
class QueryRecipeDto {
  /// Page number, 1-indexed. Defaults to `1`.
  final int page;
  /// Items per page. Defaults to `500`; backend silently clamps to 50.
  final int limit;
  /// Free-text search term. Defaults to the empty string which disables search.
  final String? query;
  /// Optional list of recipe ids for batch lookup; used by `RecipeApi.getFavoriteList`.
  final List<String>? ids;
  /// Sort order serialized via the static `Mappers.orderToJson` helper.
  @JsonKey(toJson: Mappers.orderToJson)
  final List<OrderDto>? sort;

  /// Creates a `QueryRecipeDto` with sensible defaults for list queries.
  ///
  /// Defaults: `page = 1`, `limit = 500`, `query = ''`, `ids = null`,
  /// `sort = null`. Pass through any subset to override.
  const QueryRecipeDto({
    this.page = 1,
    this.limit = 500,
    this.query = '',
    this.ids,
    this.sort,
  });

  /// Serializes to the canonical JSON shape; passed directly as
  /// `queryParameters` to Dio at `RecipeApi.getRecipeList` and
  /// `RecipeApi.getFavoriteList`.
  Map<String, dynamic> toJson() => _$QueryRecipeDtoToJson(this);
}
