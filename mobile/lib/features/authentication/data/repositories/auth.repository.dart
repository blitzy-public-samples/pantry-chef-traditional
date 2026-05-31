import 'package:pantry_chef/features/authentication/data/api/authentication.api.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

/// Dio-backed adapter between the domain AuthRepository contract and the AuthenticationApi.
///
/// Translates raw backend JSON responses into AuthResponse entities via AuthResponse.fromJson.
/// Instantiates AuthenticationApi() directly per call (no DI); a fresh API client is created
/// for each login/signup invocation — preserved as-is per the codebase's existing pattern.
class AuthRepositoryImpl extends AuthRepository {
  /// Delegates to AuthenticationApi.login and deserializes the response into an AuthResponse.
  ///
  /// Throws DioException on transport or backend errors (401/422/etc.).
  @override
  Future<AuthResponse> login(AuthDto dto) async {
    AuthenticationApi api = AuthenticationApi();
    Map<String, dynamic> response = await api.login(dto);
    return AuthResponse.fromJson(response);
  }

  /// Delegates to AuthenticationApi.signup and deserializes the response into an AuthResponse.
  ///
  /// Throws DioException on transport or backend errors (typically 422 for duplicate email).
  @override
  Future<AuthResponse> signup(AuthDto dto) async {
    AuthenticationApi api = AuthenticationApi();
    Map<String, dynamic> response = await api.signup(dto);
    return AuthResponse.fromJson(response);
  }
}
