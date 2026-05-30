import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

part 'profile_update.dto.g.dart';

/// PATCH request body for `PATCH /api/v1/users`.
///
/// All fields are optional so callers can issue partial updates. The class
/// is `@JsonSerializable()` for the generated [toJson], but also exposes
/// [toJsonWithoutNullFields] to support partial-update semantics that
/// strip null fields from the wire payload (the standard transport mode
/// used by [ProfileApi.updateProfile]).
@JsonSerializable()
class ProfileUpdateDto {
  /// New email address; omit (leave null) to leave unchanged.
  final String? email;

  /// New password; omit (leave null) to leave unchanged.
  final String? password;

  /// Replacement embedded [Preferences] value object; omit to leave unchanged.
  final Preferences? preferences;

  /// Replacement list of favorite recipe IDs; omit to leave unchanged.
  final List<String>? favoriteRecipes;

  /// Creates a [ProfileUpdateDto].
  const ProfileUpdateDto({
    this.email,
    this.password,
    this.preferences,
    this.favoriteRecipes,
  });

  /// Serializes via the `json_serializable`-generated `_$ProfileUpdateDtoToJson` helper.
  ///
  /// Includes ALL fields, including those that are null. For PATCH-style
  /// partial updates, prefer [toJsonWithoutNullFields] instead.
  Map<String, dynamic> toJson() => _$ProfileUpdateDtoToJson(this);

  /// Returns a partial JSON map containing only the non-null fields.
  ///
  /// Used for PATCH-style requests by [ProfileApi.updateProfile] to avoid
  /// clobbering unset fields on the server. Each field is conditionally
  /// added via `if (field != null)` checks; the resulting map is empty when
  /// every field is null.
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
