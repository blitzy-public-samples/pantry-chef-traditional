import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/data/repositories/auth.repository.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

/// Signs the user in, then persists the returned tokens locally.
///
/// Implements the `UseCaseWithParams<void, AuthDto>` contract — the
/// standard parameterized callable use case
/// (Source: mobile/lib/core/utils/usercase.dart:L5-L7) — so it accepts
/// an [AuthDto] of credentials and returns `Future<void>`, since its
/// purpose is the side effect of authenticating and storing tokens.
class LoginUsecase implements UseCaseWithParams<void, AuthDto> {
  /// Logs in with [dto], then stores the issued session tokens.
  ///
  /// Resolves an [AuthRepository] implementation, awaits `login([dto])`
  /// for an `AuthResponse`, then saves `result.token` and
  /// `result.refreshToken` through [SharedPreferencesHelper] obtained
  /// from the [getIt] service locator
  /// (Source: .../usecases/login.usecase.dart:L11-L16).
  @override
  Future<void> call(AuthDto dto) async {
    // Resolve the auth repository implementation via the domain contract.
    AuthRepository repo = AuthRepositoryImpl();
    // Perform the login request and await the AuthResponse tokens.
    AuthResponse result = await repo.login(dto);
    // Resolve the SharedPreferencesHelper from the getIt DI singleton.
    // KNOWN ISSUE: the leading-underscore local name is preserved as-is
    // and intentionally not renamed; it is a method-local, not a
    // private field.
    SharedPreferencesHelper _sharedPreferencesHelper = getIt<SharedPreferencesHelper>();
    // Persist access + refresh tokens for subsequent requests.
    _sharedPreferencesHelper.saveAccessToken(result.token);
    _sharedPreferencesHelper.saveRefreshToken(result.refreshToken);
  }
}
