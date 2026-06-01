import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'pantry_item.g.dart';

/// Canonical immutable domain entity for a pantry inventory record on the
/// mobile side.
///
/// Mirrors the backend `PantryIngridient` schema (spelling preserved verbatim
/// from `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts`).
/// The mobile-side class name [PantryItem] uses correct spelling, but the
/// embedded field name `ingridient` (see below) preserves the backend typo.
///
/// Marked `@JsonSerializable()`; JSON conversion is delegated to the generated
/// helpers `_$PantryItemFromJson` and `_$PantryItemToJson` in the part file
/// `pantry_item.g.dart`, produced by `json_serializable` via
/// `dart run build_runner build`. The class is immutable — all fields are
/// `final` and the constructor is `const` with required named parameters.
///
/// Consumed by `PantryBloc`, `PantryItemEditBloc`, `PantryItemCard`, and
/// `PantryRepositoryImpl`. See
/// [DATA_MODEL.md](../../../../../DATA_MODEL.md) § PantryIngridient for the
/// full schema.
@JsonSerializable()
class PantryItem {
  /// Backend-assigned MongoDB ObjectId for this pantry record.
  ///
  /// Typed as [String] because Mongoose serializes `_id` to its hex-string
  /// representation. Used as the path parameter in `PATCH` and `DELETE`
  /// requests against `/api/pantry/:id`.
  final String id;
  /// The embedded ingredient — field name `ingridient` is preserved verbatim
  /// from the backend `PantryIngridient` schema. Do not rename.
  ///
  /// The Dart class [Ingredient] itself is correctly spelled on the mobile
  /// side; only the field name carries the backend typo.
  final Ingredient ingridient;
  /// Numeric quantity of this ingredient in the pantry.
  ///
  /// Unit semantics are determined by the embedded [Ingredient.unit] (not by
  /// a `unit` field on this class). Stored as [double] to support fractional
  /// quantities such as `0.5 kg` or `1.25 L`.
  final double quantity;
  /// Storage location bucket: one of `'fridge'`, `'freezer'`, or `'pantry'`.
  ///
  /// Typed as [String] — there is no compile-time enum. Valid values are
  /// listed in `mobile/lib/core/constants/ingredient_location.dart:L1` and
  /// enforced by the backend; mismatches fail server-side validation.
  final String location;
  /// ISO-8601 timestamp string set by the backend via Mongoose's
  /// `@Schema({ timestamps: true })`.
  ///
  /// Typed as [String] (not [DateTime]) to preserve raw backend serialization;
  /// consumers parse on demand if needed.
  final String createdAt;
  /// ISO-8601 timestamp string updated by the backend on every PATCH via
  /// Mongoose's `@Schema({ timestamps: true })`.
  ///
  /// Same [String] typing rationale as [createdAt].
  final String updatedAt;
  /// Expiration date string supplied by the user or extracted from product
  /// labels by the AI workflow.
  ///
  /// ISO-8601 string used by the UI for countdown badges and sorting. Typed
  /// as [String] consistent with [createdAt] / [updatedAt]; not validated for
  /// actual ISO format at the model level.
  final String expirationDate;

  /// Const constructor taking all 7 fields as required named parameters.
  ///
  /// Enables compile-time constant [PantryItem] instances when invoked with
  /// constant arguments (rare in practice — most instances come from
  /// [PantryItem.fromJson]). There are no optional parameters.
  const PantryItem({
    required this.id,
    required this.ingridient,
    required this.quantity,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.expirationDate,
  });

  /// Deserializes a backend JSON payload into a [PantryItem] via the
  /// generated `_$PantryItemFromJson`.
  ///
  /// Used by `PantryRepositoryImpl` to convert API responses (from
  /// `createPantryItem`, `fetchPantryItems`, and `updatePantryItem`) into
  /// domain entities. Throws if required fields are missing or have wrong
  /// types in the JSON map.
  factory PantryItem.fromJson(Map<String, dynamic> json) => _$PantryItemFromJson(json);

  /// Serializes this instance to a JSON map via the generated
  /// `_$PantryItemToJson`.
  ///
  /// The output map uses field names verbatim, including `ingridient`
  /// (preserved spelling), as keys. Used by `HydratedBloc` (`PantryBloc`
  /// with `HydratedMixin`) for cached state persistence; write payloads
  /// use [CreatePantryItemDto] / [UpdatePantryItemDto] instead.
  Map<String, dynamic> toJson() => _$PantryItemToJson(this);
}
