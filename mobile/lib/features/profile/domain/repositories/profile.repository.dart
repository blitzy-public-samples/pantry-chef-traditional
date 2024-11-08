import 'package:pantry_chef/features/profile/domain/models/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();

  Future<void> updateFavoriteRecipesList(List<String> list);

  Future<void> logout();
}
