import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Lightweight, immutable ingredient-category reference entity.
///
/// A `@JsonSerializable()` value object used to classify ingredients
/// (for example, the categories offered by the add-ingredient form).
///
/// Source: mobile/lib/features/ingredient/domain/models/category.dart:L5-L8
@JsonSerializable()
class Category {
  /// The unique category identifier (`int`).
  /// Source: mobile/lib/features/ingredient/domain/models/category.dart:L7
  final int id;
  /// The category's display name.
  /// Source: mobile/lib/features/ingredient/domain/models/category.dart:L8
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  /// Builds a [Category] from the decoded [json] map by delegating to
  /// the generated `_$CategoryFromJson`.
  /// Source: mobile/lib/features/ingredient/domain/models/category.dart:L15
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Serializes this [Category] to a JSON map via the generated
  /// `_$CategoryToJson`.
  /// Source: mobile/lib/features/ingredient/domain/models/category.dart:L17
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
