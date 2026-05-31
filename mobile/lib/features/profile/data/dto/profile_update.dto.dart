import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

part 'profile_update.dto.g.dart';

/// Immutable, JSON-serializable DTO for partial profile updates.
///
/// Models patch-style updates where only changed fields are sent;
/// all fields are nullable. Supports codegen via `json_serializable`,
/// and the generated `profile_update.dto.g.dart` is never hand-edited.
@JsonSerializable()
class ProfileUpdateDto {
  /// Email to set; null leaves it unchanged.
  final String? email;
  /// Password to set; null leaves it unchanged.
  final String? password;
  /// Embedded [Preferences] to set; null leaves unchanged.
  final Preferences? preferences;
  /// Replacement list of favorite recipe ids; null skips.
  final List<String>? favoriteRecipes;

  const ProfileUpdateDto({
    this.email,
    this.password,
    this.preferences,
    this.favoriteRecipes,
  });

  /// Returns the standard JSON map via `_$ProfileUpdateDtoToJson`.
  Map<String, dynamic> toJson() => _$ProfileUpdateDtoToJson(this);

  /// Builds a patch-style map that omits all null fields.
  ///
  /// Used for `PATCH /api/users`; includes only non-null
  /// `email`, `password`, `preferences`, and `favoriteRecipes`.
  Map<String, dynamic> toJsonWithoutNullFields() {
    Map<String, dynamic> json = <String, dynamic>{};
    // Accumulate only the non-null fields into the patch map.
    // Add email only when provided.
    if (email != null) {
      json.addAll({'email': email});
    }
    // Add password only when provided.
    if (password != null) {
      json.addAll({'password': password});
    }
    // Add preferences only when provided.
    if (preferences != null) {
      json.addAll({'preferences': preferences});
    }
    // Add favoriteRecipes only when provided.
    if (favoriteRecipes != null) {
      json.addAll({'favoriteRecipes': favoriteRecipes});
    }

    return json;
  }
}
