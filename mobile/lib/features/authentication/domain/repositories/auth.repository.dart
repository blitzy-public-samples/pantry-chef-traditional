import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';

/// Authentication boundary consumed by the domain layer.
///
/// Implementations live in data/repositories/auth.repository.dart (AuthRepositoryImpl) and adapt
/// the abstract contract to the Dio-backed AuthenticationApi. Returns an AuthResponse on success;
/// throws DioException on transport or backend errors.
abstract class AuthRepository {
  /// Authenticates an existing user by email and password.
  ///
  /// Returns the issued access + refresh token pair on HTTP 200/201. Throws DioException on
  /// 401 (invalid credentials), 422 (validation), or transport errors.
  Future<AuthResponse> login(AuthDto dto);

  /// Registers a new user by email and password.
  ///
  /// Returns the issued access + refresh token pair on HTTP 201. Throws DioException on 422
  /// (e.g., email already exists) or transport errors.
  Future<AuthResponse> signup(AuthDto dto);
}
