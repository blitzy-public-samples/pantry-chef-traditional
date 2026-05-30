// NOTE: This file's name 'profile.repositiry.dart' is preserved verbatim (typo retained for stability). Do not rename.
import 'package:pantry_chef/features/profile/data/api/profile.api.dart';
import 'package:pantry_chef/features/profile/data/dto/profile_update.dto.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';

/// Concrete implementation of [ProfileRepository] for the profile feature.
///
/// Translates raw `Map<String, dynamic>` API responses into [Profile] domain
/// objects via [Profile.fromJson] and delegates write operations to
/// [ProfileApi]. Each method instantiates a fresh [ProfileApi] inline; the
/// class is stateless and does not cache responses, but the underlying `Dio`
/// is a singleton resolved from `getIt<DioClient>().dio`, so HTTP-level
/// configuration (base URL, interceptors, auth headers) is shared across calls.
///
/// Note: both this file name (`profile.repositiry.dart`) and this class name
/// (`ProfileRepositiryImpl`) preserve the intentional typo "repositiry"
/// verbatim. Do not rename either.
class ProfileRepositiryImpl implements ProfileRepository {
  /// Fetches the current user's profile and deserializes it into a [Profile].
  ///
  /// Instantiates a [ProfileApi], invokes [ProfileApi.getProfile] to retrieve
  /// the raw `Map<String, dynamic>` payload, then materializes it via
  /// [Profile.fromJson]. This method is where the raw-JSON-to-domain
  /// translation happens.
  @override
  Future<Profile> getProfile() async {
    ProfileApi api = ProfileApi();
    Map<String, dynamic> response = await api.getProfile();
    return Profile.fromJson(response);
  }

  /// Patches the current user's favorite recipes list via [ProfileApi.updateProfile].
  ///
  /// Wraps the given recipe id list in a [ProfileUpdateDto] with only the
  /// `favoriteRecipes` field populated, so that
  /// [ProfileUpdateDto.toJsonWithoutNullFields] strips all other (null)
  /// fields from the wire payload. Other user fields (email, password,
  /// embedded preferences) are left untouched server-side.
  @override
  Future<void> updateFavoriteRecipesList(List<String> list) async {
    ProfileApi api = ProfileApi();
    await api.updateProfile(ProfileUpdateDto(favoriteRecipes: list));
  }

  /// Invalidates the refresh session server-side via [ProfileApi.logout].
  ///
  /// This method is intentionally narrow — it only hits the network and does
  /// no local cleanup. Clearing access/refresh tokens from `SharedPreferences`,
  /// resetting sibling BLoCs (`PantryBloc`, `RecipeBloc`, `ProfileBloc`) and the
  /// `HomeBloc` tab, calling `HydratedBloc.storage.clear()`, and navigating back
  /// to the authentication start screen are the responsibility of `LogoutUsecase`
  /// in `domain/usecases/logout.usecase.dart`.
  @override
  Future<void> logout() async {
    ProfileApi api = ProfileApi();
    await api.logout();
  }
}
