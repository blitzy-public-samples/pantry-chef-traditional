import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Lightweight, immutable ingredient-category reference entity.
///
/// A `@JsonSerializable()` value object used to classify ingredients
/// (for example, the categories offered by the add-ingredient form).
///
@JsonSerializable()
class Category {
  /// The unique category identifier (`int`).
  final int id;
  /// The category's display name.
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  /// Builds a [Category] from the decoded [json] map by delegating to
  /// the generated `_$CategoryFromJson`.
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Serializes this [Category] to a JSON map via the generated
  /// `_$CategoryToJson`.
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
