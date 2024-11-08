import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/utils/mappers.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final String id;
  final String email;
  final List<String> favoriteRecipes;
  final List<String> recentSearches;
  @JsonKey(toJson: Mappers.preferencesToJson)
  final Preferences preferences;

  const Profile({
    required this.id,
    required this.email,
    required this.favoriteRecipes,
    required this.recentSearches,
    required this.preferences,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({final List<String>? favoriteRecipes}) => Profile(
        id: id,
        email: email,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
        recentSearches: recentSearches,
        preferences: preferences,
      );
}
