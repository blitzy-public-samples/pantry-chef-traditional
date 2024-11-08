import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/profile/data/dto/profile_update.dto.dart';

class ProfileApi {
  late final Dio _dio;

  ProfileApi() {
    _dio = getIt<DioClient>().dio;
  }

  Future<Map<String, dynamic>> getProfile() async {
    Response<dynamic> response = await _dio.get(Endpoints.profile);
    return response.data;
  }

  Future<void> updateProfile(ProfileUpdateDto dto) async {
    await _dio.patch(Endpoints.updateProfile, data: dto.toJsonWithoutNullFields());
  }

  Future<void> logout() async {
    await _dio.post(Endpoints.logout);
  }
}
