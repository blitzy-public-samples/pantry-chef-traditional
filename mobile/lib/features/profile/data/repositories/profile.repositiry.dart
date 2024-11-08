import 'package:pantry_chef/features/profile/data/api/profile.api.dart';
import 'package:pantry_chef/features/profile/data/dto/profile_update.dto.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';

class ProfileRepositiryImpl implements ProfileRepository {
  @override
  Future<Profile> getProfile() async {
    ProfileApi api = ProfileApi();
    Map<String, dynamic> response = await api.getProfile();
    return Profile.fromJson(response);
  }

  @override
  Future<void> updateFavoriteRecipesList(List<String> list) async {
    ProfileApi api = ProfileApi();
    await api.updateProfile(ProfileUpdateDto(favoriteRecipes: list));
  }

  @override
  Future<void> logout() async {
    ProfileApi api = ProfileApi();
    await api.logout();
  }
}
