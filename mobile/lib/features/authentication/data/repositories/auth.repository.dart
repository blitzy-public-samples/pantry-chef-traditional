import 'package:pantry_chef/features/authentication/data/api/authentication.api.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';
import 'package:pantry_chef/features/authentication/domain/repositories/auth.repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<AuthResponse> login(AuthDto dto) async {
    AuthenticationApi api = AuthenticationApi();
    Map<String, dynamic> response = await api.login(dto);
    return AuthResponse.fromJson(response);
  }

  @override
  Future<AuthResponse> signup(AuthDto dto) async {
    AuthenticationApi api = AuthenticationApi();
    Map<String, dynamic> response = await api.signup(dto);
    return AuthResponse.fromJson(response);
  }
}
