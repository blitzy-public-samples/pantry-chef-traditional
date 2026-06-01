import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';

/// Domain authentication contract for the authentication feature.
///
/// Defines the dependency-inversion boundary that the authentication
/// use cases (`LoginUsecase` and `SignupUsecase`) depend on, and that
/// the data layer implements via `AuthRepositoryImpl`
/// (data/repositories/auth.repository.dart).
///
/// Declares no implementation details (no network calls, persistence,
/// or token storage); it exposes only the typed asynchronous surface
/// for sign-in and registration so higher layers stay
/// implementation-agnostic and testable.
abstract class AuthRepository {
  /// Authenticates an existing user from the credentials in [dto].
  ///
  /// Resolves to an [AuthResponse] carrying the issued access and
  /// refresh tokens for the signed-in user.
  Future<AuthResponse> login(AuthDto dto);

  /// Registers a new user from the credentials in [dto].
  ///
  /// Resolves to an [AuthResponse] carrying the freshly issued access
  /// and refresh tokens for the new account.
  Future<AuthResponse> signup(AuthDto dto);
}
