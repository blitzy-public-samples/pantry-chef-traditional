import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/profile/data/dto/profile_update.dto.dart';

/// Thin, stateless remote API wrapper for the profile feature.
///
/// Centralizes the profile feature's backend HTTP calls so that
/// repositories depend on a single network boundary.
/// Resolves the shared [Dio] instance from the service locator
/// via `getIt<DioClient>().dio` in the constructor.
class ProfileApi {
  // Shared Dio HTTP client resolved from the service locator.
  late final Dio _dio;

  ProfileApi() {
    // Resolve the app-wide Dio client from the service locator.
    _dio = getIt<DioClient>().dio;
  }

  /// Issues a GET request to [Endpoints.profile] and returns the
  /// raw profile payload as a `Map<String, dynamic>`.
  Future<Map<String, dynamic>> getProfile() async {
    Response<dynamic> response = await _dio.get(Endpoints.profile);
    return response.data;
  }

  /// Sends a PATCH request to [Endpoints.updateProfile] with the
  /// body built from [dto].toJsonWithoutNullFields() so null fields
  /// are omitted (patch-style). Returns a `Future<void>`.
  Future<void> updateProfile(ProfileUpdateDto dto) async {
    await _dio.patch(Endpoints.updateProfile, data: dto.toJsonWithoutNullFields());
  }

  /// Sends a POST request to [Endpoints.logout] to terminate the
  /// backend session. Returns a `Future<void>`.
  Future<void> logout() async {
    await _dio.post(Endpoints.logout);
  }
}
