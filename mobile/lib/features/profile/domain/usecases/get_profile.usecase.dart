import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';

class GetProfileUsecase implements UseCase<Profile> {
  @override
  Future<Profile> call() async {
    ProfileRepository repo = ProfileRepositiryImpl();
    return repo.getProfile();
  }
}
