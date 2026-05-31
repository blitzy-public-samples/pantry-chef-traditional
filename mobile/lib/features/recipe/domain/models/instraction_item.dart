// NOTE: This file's name 'instraction_item.dart' and the class name 'InstractionItem' are preserved verbatim. Do not rename.
import 'package:json_annotation/json_annotation.dart';

part 'instraction_item.g.dart';

/// Domain model for a single instruction step in a `Recipe.instructions` list.
///
/// Class name and file name both preserved verbatim from backend's Instruction
/// sub-schema export naming convention (see the `// NOTE:` annotation at the top
/// of this file).
@JsonSerializable()
class InstractionItem {
  /// Step number (1-indexed).
  final int step;

  /// Step description; rendered as `'$step. $description'` in `RecipeDetailed`.
  final String description;

  /// Optional countdown in seconds for steps with a timed phase.
  final double? timer;

  /// Creates an `InstractionItem` with required `step`, `description`, and optional `timer`.
  const InstractionItem({
    required this.step,
    required this.description,
    this.timer,
  });

  /// Deserializes from JSON via the generated factory.
  factory InstractionItem.fromJson(Map<String, dynamic> json) => _$InstractionItemFromJson(json);

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => _$InstractionItemToJson(this);
}
