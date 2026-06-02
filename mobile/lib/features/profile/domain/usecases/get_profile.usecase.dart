import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';

/// Stateless use case that loads the current user's [Profile].
///
/// Implements the no-arg [UseCase] contract; constructs the data-layer
/// repository on each invocation and delegates the read to it.
class GetProfileUsecase implements UseCase<Profile> {
  /// Loads and returns the current user's [Profile].
  ///
  /// Instantiates `ProfileRepositiryImpl` (intentional misspelling) and
  /// assigns it to the correctly-spelled [ProfileRepository] interface,
  /// then returns the result of `repo.getProfile()`.
  @override
  Future<Profile> call() async {
    // Bind the misspelled impl to the correctly-spelled interface.
    ProfileRepository repo = ProfileRepositiryImpl();
    // Delegate the profile read to the repository.
    return repo.getProfile();
  }
}
