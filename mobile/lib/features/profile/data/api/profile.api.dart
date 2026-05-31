import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/profile/data/dto/profile_update.dto.dart';

/// Network adapter for the profile feature.
///
/// Wraps [Dio] calls to the backend auth and users endpoints
/// (`/api/auth/me`, `/api/users`, `/api/auth/logout`) using the
/// shared [DioClient] resolved from the [getIt] service locator
/// (`getIt<DioClient>().dio`). Stateless except for the captured Dio
/// reference; the class does not cache responses, manage lifecycle, or
/// own retry/interceptor logic — those concerns live in `DioClient`.
class ProfileApi {
  late final Dio _dio;

  /// Creates a [ProfileApi] backed by the shared [DioClient] from [getIt].
  ///
  /// Captures `getIt<DioClient>().dio` into the private `_dio` field for
  /// the lifetime of this instance. Because [DioClient] is registered as a
  /// singleton in `service_locator.dart`, every `ProfileApi` instance shares
  /// the same underlying Dio configuration (interceptors, base URL, headers,
  /// auth handling).
  ProfileApi() {
    _dio = getIt<DioClient>().dio;
  }

  /// Fetches the current user's profile via `GET Endpoints.profile`.
  ///
  /// Issues `GET /api/auth/me`. Returns the raw decoded JSON map; the
  /// caller is expected to deserialize via `Profile.fromJson` (typically in
  /// [ProfileRepositiryImpl.getProfile], file name typo preserved verbatim).
  Future<Map<String, dynamic>> getProfile() async {
    Response<dynamic> response = await _dio.get(Endpoints.profile);
    return response.data;
  }

  /// Patches the current user via `PATCH Endpoints.updateProfile`.
  ///
  /// Issues `PATCH /api/users` with the body produced by
  /// [ProfileUpdateDto.toJsonWithoutNullFields], which omits null fields so
  /// the server does not clobber unset properties — supporting safe partial
  /// updates of email, password, embedded preferences, and favorite recipes.
  Future<void> updateProfile(ProfileUpdateDto dto) async {
    await _dio.patch(Endpoints.updateProfile, data: dto.toJsonWithoutNullFields());
  }

  /// Invalidates the refresh session server-side via `POST Endpoints.logout`.
  ///
  /// Issues `POST /api/auth/logout`. Does NOT clear local tokens or
  /// hydrated BLoC state — that responsibility lives in `LogoutUsecase`
  /// (`domain/usecases/logout.usecase.dart`).
  Future<void> logout() async {
    await _dio.post(Endpoints.logout);
  }
}
