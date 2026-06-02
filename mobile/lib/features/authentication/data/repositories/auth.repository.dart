import 'package:pantry_chef/features/authentication/data/api/authentication.api.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

/// Data-layer implementation of the domain [AuthRepository] contract.
///
/// Adapts the raw `Map<String, dynamic>` returned by [AuthenticationApi]
/// into the [AuthResponse] domain entity for the sign-in and sign-up
/// flows. The class is stateless: it holds no fields and creates a new
/// [AuthenticationApi] on demand inside each method.
/// Source: .../domain/repositories/auth.repository.dart:L15
class AuthRepositoryImpl extends AuthRepository {
  /// Authenticates an existing user with the credentials in [dto].
  ///
  /// Sends [dto] to the backend via [AuthenticationApi.login] and maps
  /// the raw `Map<String, dynamic>` response into an [AuthResponse]
  /// through [AuthResponse.fromJson].
  @override
  Future<AuthResponse> login(AuthDto dto) async {
    // Instantiates the API client on demand (stateless repository).
    AuthenticationApi api = AuthenticationApi();
    Map<String, dynamic> response = await api.login(dto);
    return AuthResponse.fromJson(response);
  }

  /// Registers a new user with the credentials in [dto].
  ///
  /// Sends [dto] to the backend via [AuthenticationApi.signup] and maps
  /// the raw `Map<String, dynamic>` response into an [AuthResponse]
  /// through [AuthResponse.fromJson].
  @override
  Future<AuthResponse> signup(AuthDto dto) async {
    // Instantiates the API client on demand (stateless repository).
    AuthenticationApi api = AuthenticationApi();
    Map<String, dynamic> response = await api.signup(dto);
    return AuthResponse.fromJson(response);
  }
}
