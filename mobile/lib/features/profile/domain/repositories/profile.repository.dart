import 'package:pantry_chef/features/profile/domain/models/profile.dart';

/// Domain-layer contract for profile data and session operations.
///
/// Defines the abstract API the profile feature uses to read the
/// current [Profile], synchronize favorite recipes, and end the
/// session, without binding to any persistence or network detail.
///
/// Note: this domain interface name `ProfileRepository` is correctly
/// spelled. The data-layer implementation is `ProfileRepositiryImpl`
/// in `features/profile/data/repositories/profile.repositiry.dart`,
/// which carries an intentional misspelling (`Repositiry`). Both
/// identifiers are intentional and must not be renamed.
abstract class ProfileRepository {
  /// Returns the current user's [Profile] from the backing source.
  Future<Profile> getProfile();

  /// Persists/synchronizes the user's favorite-recipe id list.
  ///
  /// [list] holds the recipe ids that make up the favorites set.
  Future<void> updateFavoriteRecipesList(List<String> list);

  /// Terminates the current authenticated session (side-effect only).
  Future<void> logout();
}
