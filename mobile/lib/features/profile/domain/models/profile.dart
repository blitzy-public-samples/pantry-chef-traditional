import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/utils/mappers.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

part 'profile.g.dart';

/// Client-side domain entity mirroring the backend `User` document.
///
/// Carries the user identifier ([id]), [email], favorite recipe IDs
/// ([favoriteRecipes]), [recentSearches], and the embedded [Preferences]
/// value object. The `@JsonSerializable()` annotation generates serialization
/// helpers in `profile.g.dart` (a generated `part` file).
///
/// See [../../../../DATA_MODEL.md](../../../../DATA_MODEL.md) § User collection
/// for the canonical schema documentation including the embedded `Preferences`
/// subdocument, the `deletedAt` soft-delete contract, and the timestamps
/// (`createdAt`/`updatedAt`) convention.
@JsonSerializable()
class Profile {
  /// The MongoDB document `_id` from the backend `User` collection.
  ///
  /// Persistent and immutable; used as the foreign-key target by other entities
  /// (e.g., `PantryIngridient.userId` — spelling `Ingridient` preserved verbatim).
  final String id;
  /// The user's login email address.
  ///
  /// The backend ensures uniqueness via a Mongoose unique index; the mobile app
  /// does not validate this constraint client-side beyond the basic shape regex.
  final String email;
  /// List of `Recipe` IDs that the user has favorited.
  ///
  /// Full `Recipe` objects are fetched on demand by the BLoC (via
  /// `RecipeRepository.getFavoriteList(ids)`). Storing only IDs here keeps the
  /// profile payload compact.
  final List<String> favoriteRecipes;
  /// Recent search query strings retained for UX features.
  ///
  /// Currently not surfaced in any UI screen — captured in the backend for
  /// future search-history features.
  final List<String> recentSearches;
  /// Embedded [Preferences] value object (dietary, allergies, dislikedIngredients,
  /// cookingTime).
  ///
  /// Serialized via the custom [Mappers.preferencesToJson] mapper to keep DTO files
  /// free of feature-specific imports (see `mobile/lib/core/utils/mappers.dart`).
  @JsonKey(toJson: Mappers.preferencesToJson)
  final Preferences preferences;

  /// Creates an immutable [Profile].
  const Profile({
    required this.id,
    required this.email,
    required this.favoriteRecipes,
    required this.recentSearches,
    required this.preferences,
  });

  /// Deserializes a [Profile] from JSON.
  ///
  /// Delegates to the json_serializable-generated `_$ProfileFromJson` in `profile.g.dart`.
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// Serializes this [Profile] to JSON.
  ///
  /// Delegates to the generated `_$ProfileToJson` in `profile.g.dart`, which uses
  /// `Mappers.preferencesToJson` for the nested `preferences` field per `@JsonKey`.
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  /// Returns a new [Profile] with [favoriteRecipes] replaced; all other fields
  /// are preserved.
  ///
  /// Only the `favoriteRecipes` parameter is exposed; the other fields ([id],
  /// [email], [recentSearches], [preferences]) are intentionally not part of the
  /// `copyWith` API. Callers expecting `copyWith(email: ...)` or
  /// `copyWith(preferences: ...)` to work will be surprised — those parameters
  /// are not exposed.
  Profile copyWith({final List<String>? favoriteRecipes}) => Profile(
        id: id,
        email: email,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
        recentSearches: recentSearches,
        preferences: preferences,
      );
}
