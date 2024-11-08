import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'search.dto.g.dart';

@JsonSerializable()
class SearchDto {
  final String query;
  final int page;
  final int limit;
  @JsonKey(toJson: Mappers.orderToJson)
  final List<OrderDto>? sort;

  const SearchDto({
    required this.query,
    required this.page,
    required this.limit,
    this.sort,
  });

  Map<String, dynamic> toJson() => _$SearchDtoToJson(this);
}
