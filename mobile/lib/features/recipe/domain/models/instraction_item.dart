import 'package:json_annotation/json_annotation.dart';

part 'instraction_item.g.dart';

@JsonSerializable()
class InstractionItem {
  final int step;
  final String description;
  final double? timer;

  const InstractionItem({
    required this.step,
    required this.description,
    this.timer,
  });

  factory InstractionItem.fromJson(Map<String, dynamic> json) => _$InstractionItemFromJson(json);

  Map<String, dynamic> toJson() => _$InstractionItemToJson(this);
}
