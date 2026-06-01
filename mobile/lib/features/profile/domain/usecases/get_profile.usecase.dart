import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';

/// Application-layer entry point for loading the current user's profile.
///
/// Implements [UseCase] over [Profile] from core `usercase.dart` (filename typo
/// preserved verbatim — the `UseCase` class itself is spelled correctly). [call]
/// builds [ProfileRepositiryImpl] (typo preserved) directly — no GetIt lookup,
/// unlike the DI pattern elsewhere — treats it as a [ProfileRepository], and
/// delegates the fetch to `repo.getProfile()`. Stateless; safe to call repeatedly.
class GetProfileUsecase implements UseCase<Profile> {
  /// Executes the use case and returns the materialized [Profile]. Instantiates
  /// [ProfileRepositiryImpl] (typo preserved) and delegates to
  /// `repo.getProfile()`. Any `DioException` propagated from the network layer
  /// surfaces from this call — it is not caught here.
  @override
  Future<Profile> call() async {
    ProfileRepository repo = ProfileRepositiryImpl();
    return repo.getProfile();
  }
}
