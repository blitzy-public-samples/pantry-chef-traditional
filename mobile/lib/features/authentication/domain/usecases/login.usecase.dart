import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/data/repositories/auth.repository.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

class LoginUsecase implements UseCaseWithParams<void, AuthDto> {
  @override
  Future<void> call(AuthDto dto) async {
    AuthRepository repo = AuthRepositoryImpl();
    AuthResponse result = await repo.login(dto);
    SharedPreferencesHelper _sharedPreferencesHelper = getIt<SharedPreferencesHelper>();
    _sharedPreferencesHelper.saveAccessToken(result.token);
    _sharedPreferencesHelper.saveRefreshToken(result.refreshToken);
  }
}
