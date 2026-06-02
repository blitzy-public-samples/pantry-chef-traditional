import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

/// Lightweight, immutable measurement-unit reference entity.
///
/// A `@JsonSerializable()` value object used to label ingredient
/// quantities (for example, the units offered by the add-ingredient form).
///
@JsonSerializable()
class Unit {
  /// The unique unit identifier (`int`).
  final int id;
  /// The unit's display name.
  final String name;

  const Unit({
    required this.id,
    required this.name,
  });

  /// Builds a [Unit] from the decoded [json] map by delegating to
  /// the generated `_$UnitFromJson`.
  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  /// Serializes this [Unit] to a JSON map via the generated
  /// `_$UnitToJson`.
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
