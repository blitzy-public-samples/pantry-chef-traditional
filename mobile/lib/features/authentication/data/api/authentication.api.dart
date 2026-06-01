import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';

/// Network client for authentication backend calls.
///
/// Resolves the shared [Dio] instance from `getIt<DioClient>()` (the
/// service locator) and exposes raw login/signup `POST` operations. Each
/// method returns the unmapped `Map<String, dynamic>` response body; domain
/// mapping is handled by the repository layer, not here.
/// Source: .../data/api/authentication.api.dart:L7
class AuthenticationApi {
  // Shared Dio client resolved via DI from getIt<DioClient>().dio.
  late final Dio _dio;

  AuthenticationApi() {
    // Resolve the shared Dio from the DioClient registered in getIt.
    _dio = getIt<DioClient>().dio;
  }

  /// POSTs the serialized [dto] (`dto.toJson()`) to `Endpoints.login` and
  /// returns the raw `Map<String, dynamic>` response body.
  ///
  /// The endpoint resolves to `<apiBaseUrl>/auth/email/login`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L12
  /// Source: .../data/api/authentication.api.dart:L14-L20
  Future<Map<String, dynamic>> login(AuthDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.login,
      data: dto.toJson(),
    );
    // Returns raw response.data; mapping handled by the repository.
    // KNOWN ISSUE: response.data is returned as Map<String, dynamic> with
    // no null/shape guard (existing behavior; not changed here).
    return response.data;
  }

  /// POSTs the serialized [dto] (`dto.toJson()`) to `Endpoints.signup` and
  /// returns the raw `Map<String, dynamic>` response body.
  ///
  /// The endpoint resolves to `<apiBaseUrl>/auth/email/register`.
  /// Source: mobile/lib/core/constants/endpoints.dart:L13
  /// Source: .../data/api/authentication.api.dart:L22-L28
  Future<Map<String, dynamic>> signup(AuthDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.signup,
      data: dto.toJson(),
    );
    // Returns raw response.data; mapping handled by the repository.
    return response.data;
  }
}
