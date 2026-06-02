import 'package:pantry_chef/features/profile/data/api/profile.api.dart';
import 'package:pantry_chef/features/profile/data/dto/profile_update.dto.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';

/// Concrete data-layer repository for the profile feature.
///
/// Implements the domain [ProfileRepository] contract by bridging it
/// to the remote [ProfileApi]. The class is lightweight and stateless:
/// it caches nothing and retains no client, instantiating a fresh
/// [ProfileApi] on each call.
///
/// Note: both the filename `profile.repositiry.dart` and the class
/// `ProfileRepositiryImpl` carry the intentional, stable "Repositiry"
/// misspelling, while the implemented interface `ProfileRepository` is
/// correctly spelled. These identifiers are preserved as-is and are
/// never renamed.
class ProfileRepositiryImpl implements ProfileRepository {
  /// Fetches the raw profile map via [ProfileApi.getProfile] and maps
  /// it to a [Profile] domain model with [Profile.fromJson].
  ///
  /// Returns the resolved [Profile].
  @override
  Future<Profile> getProfile() async {
    // Use a fresh ProfileApi instance for this call (stateless).
    ProfileApi api = ProfileApi();
    // Retrieve the backend payload as a raw JSON-like map.
    Map<String, dynamic> response = await api.getProfile();
    // Map the transport payload into the typed domain model.
    return Profile.fromJson(response);
  }

  /// Wraps [list] in a ProfileUpdateDto(favoriteRecipes: ...) and
  /// forwards it to [ProfileApi.updateProfile] (PATCH).
  ///
  /// [list] holds the favorite recipe ids to persist.
  @override
  Future<void> updateFavoriteRecipesList(List<String> list) async {
    // Use a fresh ProfileApi instance for this call (stateless).
    ProfileApi api = ProfileApi();
    // Wrap the ids in the update DTO and send as a PATCH request.
    await api.updateProfile(ProfileUpdateDto(favoriteRecipes: list));
  }

  /// Delegates to [ProfileApi.logout] (POST) to end the backend session.
  @override
  Future<void> logout() async {
    // Use a fresh ProfileApi instance for this call (stateless).
    ProfileApi api = ProfileApi();
    // Terminate the session on the backend.
    await api.logout();
  }
}
