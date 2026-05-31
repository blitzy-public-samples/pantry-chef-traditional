import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/data/repositories/auth.repository.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

/// Orchestrates the email-signup workflow end to end.
///
/// Mirrors LoginUsecase but invokes AuthRepositoryImpl.signup. The same AuthDto (email +
/// password) is reused; on success the issued access + refresh tokens are persisted via
/// SharedPreferencesHelper just like the login path.
class SignupUsecase implements UseCaseWithParams<void, AuthDto> {
  /// Runs the signup pipeline: AuthRepositoryImpl.signup -> SharedPreferencesHelper persist.
  ///
  /// Returns void; tokens are persisted internally so the caller (AuthBloc) does not need to
  /// handle the AuthResponse directly.
  @override
  Future<void> call(AuthDto dto) async {
    AuthRepository repo = AuthRepositoryImpl();
    AuthResponse result = await repo.signup(dto);
    SharedPreferencesHelper _sharedPreferencesHelper = getIt<SharedPreferencesHelper>();
    _sharedPreferencesHelper.saveAccessToken(result.token);
    _sharedPreferencesHelper.saveRefreshToken(result.refreshToken);
  }
}
