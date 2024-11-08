import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';

class AuthenticationApi {
  late final Dio _dio;

  AuthenticationApi() {
    _dio = getIt<DioClient>().dio;
  }

  Future<Map<String, dynamic>> login(AuthDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.login,
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> signup(AuthDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.signup,
      data: dto.toJson(),
    );
    return response.data;
  }
}
