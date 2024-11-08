import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/data/dto/order.dto.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'query_recipe.dto.g.dart';

@JsonSerializable()
class QueryRecipeDto {
  final int page;
  final int limit;
  final String? query;
  final List<String>? ids;
  @JsonKey(toJson: Mappers.orderToJson)
  final List<OrderDto>? sort;

  const QueryRecipeDto({
    this.page = 1,
    this.limit = 500,
    this.query = '',
    this.ids,
    this.sort,
  });

  Map<String, dynamic> toJson() => _$QueryRecipeDtoToJson(this);
}
