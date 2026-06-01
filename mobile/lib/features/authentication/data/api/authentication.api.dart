import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';

/// Thin Dio wrapper for the backend authentication endpoints.
///
/// Resolves the shared DioClient via getIt and exposes login/signup methods that POST a JSON-
/// serialized AuthDto to /auth/email/login and /auth/email/register respectively. Returns the
/// raw response.data Map so the data-layer repository can deserialize via AuthResponse.fromJson.
class AuthenticationApi {
  late final Dio _dio;

  /// Constructs the API client, resolving DioClient from the GetIt service locator.
  AuthenticationApi() {
    _dio = getIt<DioClient>().dio;
  }

  /// POSTs the credentials to /auth/email/login and returns the raw JSON response.
  ///
  /// Throws DioException on 401 (invalid credentials), 422 (validation error), or transport
  /// failures. The caller is responsible for parsing the returned map into an AuthResponse.
  Future<Map<String, dynamic>> login(AuthDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.login,
      data: dto.toJson(),
    );
    return response.data;
  }

  /// POSTs the credentials to /auth/email/register and returns the raw JSON response.
  ///
  /// Throws DioException on 422 (e.g., email already exists) or transport failures. Returns
  /// the same {token, refreshToken} payload shape as login on success.
  Future<Map<String, dynamic>> signup(AuthDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.signup,
      data: dto.toJson(),
    );
    return response.data;
  }
}
