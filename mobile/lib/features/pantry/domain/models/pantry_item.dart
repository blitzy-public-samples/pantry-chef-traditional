import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'pantry_item.g.dart';

/// Immutable pantry inventory record for the pantry feature.
///
/// Represents one entry of an ingredient stored in the user's pantry.
/// A `@JsonSerializable()` value object backed by the generated
/// `pantry_item.g.dart` part for JSON encode/decode.
///
/// Its nested `ingridient` is a strongly-typed [Ingredient] domain
/// object rather than a raw map.
///
/// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L6-L9
/// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L9
@JsonSerializable()
class PantryItem {
  /// The unique pantry item identifier (`String`).
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L8
  final String id;
  /// The associated [Ingredient] stored in the pantry. The field
  /// name `ingridient` is misspelled (sic) but is a stable
  /// identifier and the type `Ingredient` is correct; document,
  /// never rename.
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L9
  final Ingredient ingridient;
  /// Quantity of the ingredient in the pantry (`double`).
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L10
  final double quantity;
  /// Storage location of the item.
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L11
  final String location;
  /// Creation timestamp (string).
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L12
  final String createdAt;
  /// Last-updated timestamp (string).
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L13
  final String updatedAt;
  /// Expiration date of the item (string).
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L14
  final String expirationDate;

  /// Builds an immutable [PantryItem] with all required fields.
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L16-L24
  const PantryItem({
    required this.id,
    required this.ingridient,
    required this.quantity,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.expirationDate,
  });

  /// Builds a [PantryItem] from the decoded [json] map by delegating
  /// to the generated `_$PantryItemFromJson` helper.
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L26
  factory PantryItem.fromJson(Map<String, dynamic> json) => _$PantryItemFromJson(json);

  /// Serializes this [PantryItem] to a JSON map via the generated
  /// `_$PantryItemToJson` helper.
  /// Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L28
  Map<String, dynamic> toJson() => _$PantryItemToJson(this);
}
