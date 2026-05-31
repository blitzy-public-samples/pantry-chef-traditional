import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

/// Lightweight, immutable measurement-unit reference entity.
///
/// A `@JsonSerializable()` value object used to label ingredient
/// quantities (for example, the units offered by the add-ingredient form).
///
/// Source: mobile/lib/features/ingredient/domain/models/unit.dart:L5-L8
@JsonSerializable()
class Unit {
  /// The unique unit identifier (`int`).
  /// Source: mobile/lib/features/ingredient/domain/models/unit.dart:L7
  final int id;
  /// The unit's display name.
  /// Source: mobile/lib/features/ingredient/domain/models/unit.dart:L8
  final String name;

  const Unit({
    required this.id,
    required this.name,
  });

  /// Builds a [Unit] from the decoded [json] map by delegating to
  /// the generated `_$UnitFromJson`.
  /// Source: mobile/lib/features/ingredient/domain/models/unit.dart:L15
  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  /// Serializes this [Unit] to a JSON map via the generated
  /// `_$UnitToJson`.
  /// Source: mobile/lib/features/ingredient/domain/models/unit.dart:L17
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
