import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/utils/mappers.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

part 'profile.g.dart';

/// Immutable, JSON-serializable user profile aggregate.
///
/// Composes account identity, the favorite-recipe and recent-search
/// lists, and the embedded [Preferences]. JSON conversion is handled
/// by generated helpers in the `profile.g.dart` part file.
@JsonSerializable()
class Profile {
  /// Unique profile/user identifier.
  final String id;
  /// Account email address.
  final String email;
  /// Identifiers of recipes the user has favorited.
  final List<String> favoriteRecipes;
  /// Recent search terms entered by the user.
  final List<String> recentSearches;
  /// Embedded preferences; serialized via [Mappers.preferencesToJson].
  @JsonKey(toJson: Mappers.preferencesToJson)
  final Preferences preferences;

  const Profile({
    required this.id,
    required this.email,
    required this.favoriteRecipes,
    required this.recentSearches,
    required this.preferences,
  });

  /// Creates a [Profile] from a decoded JSON [json] map.
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// Converts this [Profile] to its JSON map representation.
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  /// Returns a copy of this [Profile] with [favoriteRecipes] replaced.
  ///
  /// Applies the new [favoriteRecipes] when provided, otherwise keeps
  /// the current value, and carries `id`, `email`, `recentSearches`,
  /// and `preferences` through unchanged. This correctly applies the
  /// update, in contrast to `Recipe.copyWith` whose `inFavorite`
  /// parameter is unused (a no-op).
  Profile copyWith({final List<String>? favoriteRecipes}) => Profile(
        id: id,
        email: email,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
        recentSearches: recentSearches,
        preferences: preferences,
      );
}
