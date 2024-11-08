import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/entities/auth_response.entity.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(AuthDto dto);

  Future<AuthResponse> signup(AuthDto dto);
}
