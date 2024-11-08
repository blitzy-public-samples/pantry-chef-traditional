import 'package:json_annotation/json_annotation.dart';

part 'order.dto.g.dart';

@JsonSerializable()
class OrderDto {
  final String orderBy;
  final String order;

  const OrderDto({
    required this.orderBy,
    required this.order,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);
}
