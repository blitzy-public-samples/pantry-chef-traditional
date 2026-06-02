import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/pantry/data/dto/index.dart';

/// Thin HTTP adapter for the pantry REST resource.
///
/// Does not configure networking itself; it resolves the shared,
/// pre-configured [Dio] client through dependency injection via
/// `getIt<DioClient>().dio`. Every call targets the pantry endpoint.
///
/// Routes use `/api/<resource>` with no `/v1/` segment:
/// `Endpoints.pantry` resolves to `<apiBaseUrl>/pantry`, and
/// `apiBaseUrl` already includes `/api`.
class PantryApi {
  // Shared, pre-configured Dio client used for all pantry calls.
  late final Dio _dio;

  PantryApi() {
    // Resolve the shared Dio client from the service locator.
    _dio = getIt<DioClient>().dio;
  }

  /// Issues `GET /api/pantry` and returns the unwrapped `data` list
  /// from the response envelope (`response.data['data']`).
  ///
  /// Returns a `Future<List<dynamic>>`.
  Future<List<dynamic>> fetchPantryItems() async {
    Response<dynamic> response = await _dio.get(Endpoints.pantry);
    return response.data['data'];
  }

  /// Issues `POST /api/pantry` with [dto] serialized via
  /// `dto.toJson()`; returns the response payload as a
  /// `Future<Map<String, dynamic>>`.
  Future<Map<String, dynamic>> createPantryItem(CreatePantryItemDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.pantry,
      data: dto.toJson(),
    );
    return response.data;
  }

  /// Issues `PATCH /api/pantry/:id`, building the path from
  /// `Endpoints.pantry` and the [dto] id; sends `dto.toJson()` and
  /// returns a `Future<Map<String, dynamic>>`.
  Future<Map<String, dynamic>> updatePantryItem(UpdatePantryItemDto dto) async {
    Response<dynamic> response = await _dio.patch(
      '${Endpoints.pantry}/${dto.id}',
      data: dto.toJson(),
    );
    return response.data;
  }

  /// Issues `DELETE /api/pantry/:id` for the given [id].
  ///
  /// Declared `Future<void>`.
  Future<void> deletePantryItem(String id) async {
    Response<dynamic> response = await _dio.delete('${Endpoints.pantry}/$id');
    return response.data;
  }
}
