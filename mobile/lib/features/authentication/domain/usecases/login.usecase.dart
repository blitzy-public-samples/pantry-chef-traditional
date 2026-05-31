import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/data/repositories/auth.repository.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

/// Orchestrates the email-login workflow end to end.
///
/// Instantiates the data-layer AuthRepositoryImpl directly (no DI), invokes its login method,
/// then persists the returned JWT access and refresh tokens to SharedPreferences via
/// SharedPreferencesHelper (resolved from the GetIt service locator).
class LoginUsecase implements UseCaseWithParams<void, AuthDto> {
  /// Runs the login pipeline: AuthRepositoryImpl.login -> SharedPreferencesHelper persist.
  ///
  /// Returns void because the resulting tokens are persisted inside this method; the caller
  /// (AuthBloc) does not need to handle the AuthResponse directly.
  @override
  Future<void> call(AuthDto dto) async {
    AuthRepository repo = AuthRepositoryImpl();
    AuthResponse result = await repo.login(dto);
    SharedPreferencesHelper _sharedPreferencesHelper = getIt<SharedPreferencesHelper>();
    _sharedPreferencesHelper.saveAccessToken(result.token);
    _sharedPreferencesHelper.saveRefreshToken(result.refreshToken);
  }
}
