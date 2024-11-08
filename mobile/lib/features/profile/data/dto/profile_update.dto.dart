import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

part 'profile_update.dto.g.dart';

@JsonSerializable()
class ProfileUpdateDto {
  final String? email;
  final String? password;
  final Preferences? preferences;
  final List<String>? favoriteRecipes;

  const ProfileUpdateDto({
    this.email,
    this.password,
    this.preferences,
    this.favoriteRecipes,
  });

  Map<String, dynamic> toJson() => _$ProfileUpdateDtoToJson(this);

  Map<String, dynamic> toJsonWithoutNullFields() {
    Map<String, dynamic> json = <String, dynamic>{};
    if (email != null) {
      json.addAll({'email': email});
    }
    if (password != null) {
      json.addAll({'password': password});
    }
    if (preferences != null) {
      json.addAll({'preferences': preferences});
    }
    if (favoriteRecipes != null) {
      json.addAll({'favoriteRecipes': favoriteRecipes});
    }

    return json;
  }
}
