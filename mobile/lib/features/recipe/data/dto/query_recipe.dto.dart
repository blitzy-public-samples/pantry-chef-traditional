import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/data/dto/order.dto.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'query_recipe.dto.g.dart';

/// Immutable query/pagination DTO for recipe list requests.
@JsonSerializable()
class QueryRecipeDto {
  /// 1-based page index (default `1`).
  final int page;
  /// Requested page size (default `500`; backend caps results at 50).
  final int limit;
  /// Optional free-text search term (default `''`).
  final String? query;
  /// Optional recipe ids to filter by (used for favorites).
  final List<String>? ids;
  /// Optional sort descriptors, JSON-encoded via `Mappers.orderToJson`.
  @JsonKey(toJson: Mappers.orderToJson)
  final List<OrderDto>? sort;

  const QueryRecipeDto({
    this.page = 1,
    this.limit = 500,
    this.query = '',
    this.ids,
    this.sort,
  });

  /// Serializes via the generated `_$QueryRecipeDtoToJson`.
  Map<String, dynamic> toJson() => _$QueryRecipeDtoToJson(this);
}
