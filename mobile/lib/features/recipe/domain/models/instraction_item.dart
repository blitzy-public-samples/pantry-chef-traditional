import 'package:json_annotation/json_annotation.dart';

part 'instraction_item.g.dart';

/// Immutable, JSON-serializable recipe instruction step model.
///
/// The class name spelling `InstractionItem` (sic) is intentional
/// and preserved as a stable identifier (not a typo to fix).
/// JSON conversion is generated via `part 'instraction_item.g.dart'`.
@JsonSerializable()
class InstractionItem {
  /// Ordered step number.
  final int step;
  /// Human-readable step text.
  final String description;
  /// Optional timer/duration for the step (nullable).
  final double? timer;

  const InstractionItem({
    required this.step,
    required this.description,
    this.timer,
  });

  /// Creates an [InstractionItem] from a JSON map [json].
  factory InstractionItem.fromJson(Map<String, dynamic> json) => _$InstractionItemFromJson(json);

  /// Converts this [InstractionItem] to a JSON map.
  Map<String, dynamic> toJson() => _$InstractionItemToJson(this);
}
