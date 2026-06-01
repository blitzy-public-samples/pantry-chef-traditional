import 'package:pantry_chef/features/profile/domain/models/profile.dart';

/// Abstract repository contract for the profile feature.
///
/// The concrete implementation lives at
/// `mobile/lib/features/profile/data/repositories/profile.repositiry.dart`
/// (filename typo `repositiry` preserved verbatim) and is named
/// [ProfileRepositiryImpl] (class-name typo preserved verbatim — NOT
/// `ProfileRepositoryImpl`).
///
/// Consumed by [GetProfileUsecase], [FavoriteRecipesUpdateUsecase], and
/// [LogoutUsecase]. Each use case declares `ProfileRepository` as the
/// variable type but instantiates `ProfileRepositiryImpl()` directly inline
/// (no GetIt lookup) — the abstraction is consumed by static type, not via
/// runtime DI binding.
abstract class ProfileRepository {
  /// Returns the currently authenticated user's [Profile], deserialized from the backend response.
  ///
  /// Invokes a GET against `Endpoints.profile` (`<API_BASE_URL>/auth/me`) via
  /// the data-layer `ProfileApi`. Throws `DioException` on network or auth
  /// failure; also throws if JSON deserialization into [Profile] fails.
  Future<Profile> getProfile();

  /// Replaces the server-side `favoriteRecipes` array with the provided [list].
  ///
  /// The [list] parameter is the COMPLETE new favorites list (not a delta).
  /// The concrete implementation wraps it in `ProfileUpdateDto(favoriteRecipes: list)`
  /// and PATCHes the user document; OTHER user fields (email, password,
  /// preferences) are left untouched because `ProfileUpdateDto.toJsonWithoutNullFields`
  /// omits null entries from the payload.
  Future<void> updateFavoriteRecipesList(List<String> list);

  /// Invalidates the server-side refresh session via `POST <API_BASE_URL>/auth/logout`.
  ///
  /// This method does NOT perform any local cleanup — no SharedPreferences
  /// clearing, no BLoC reset, no navigation. All local teardown is the
  /// caller's responsibility; see [LogoutUsecase] for the full client-side
  /// teardown sequence (token removal, BLoC resets, HydratedBloc storage
  /// clear, and navigation back to the auth start route).
  Future<void> logout();
}
