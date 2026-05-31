import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/pantry/data/dto/index.dart';

/// Direct HTTP adapter for the pantry feature's CRUD operations against the
/// backend `/api/v1/pantry/*` endpoints.
///
/// Resolves the shared [DioClient] via the GetIt service locator
/// (`getIt<DioClient>().dio`) and reuses its authenticated [Dio] instance; see
/// `mobile/lib/core/utils/dio_client.dart` for that client (bearer-JWT injection
/// plus 401/419 token-refresh handling). The base URL constant `Endpoints.pantry`
/// (Source: `mobile/lib/core/constants/endpoints.dart:L26`) resolves to
/// `$apiBaseUrl/pantry`.
///
/// Authentication is automatic: a request interceptor adds the
/// `Authorization: Bearer <jwt>` header on every outbound call
/// (Source: `mobile/lib/core/utils/dio_client.dart:L35-L41`), so this adapter
/// never sets auth headers itself. Consumed exclusively by `PantryRepositoryImpl`
/// (`mobile/lib/features/pantry/data/repositories/pantry.repository.dart`), which
/// deserializes the raw JSON into domain `PantryItem` models. The adapter is
/// stateless apart from the cached [_dio] reference; each method is independent.
class PantryApi {
  late final Dio _dio;

  /// Constructs the adapter, caching the authenticated [Dio] from the
  /// GetIt-registered [DioClient] (`getIt<DioClient>().dio`).
  ///
  /// [DioClient] must be registered first; the bootstrap in
  /// `mobile/lib/core/utils/service_locator.dart` (`setupLocator()` at L8-L15)
  /// guarantees this when `main.dart:L18` awaits it before `runApp(...)`.
  PantryApi() {
    _dio = getIt<DioClient>().dio;
  }

  /// Issues a GET to `Endpoints.pantry` and returns the nested `data` payload
  /// from the response envelope.
  ///
  /// The backend wraps the list in a `data` key (raw shape `{ "data": [...] }`),
  /// so this unwraps and returns `response.data['data']`; it is the only method
  /// here that unwraps an inner key (POST/PATCH/DELETE return `response.data`
  /// directly). The backend caps results at 50 records (pagination cap). The
  /// returned `List<dynamic>` is deserialized by the repository layer. Auth is
  /// automatic via the [DioClient] interceptor; throws `DioException` on network
  /// failure or a non-2xx response.
  Future<List<dynamic>> fetchPantryItems() async {
    Response<dynamic> response = await _dio.get(Endpoints.pantry);
    return response.data['data'];
  }

  /// POSTs the serialized [dto] (`dto.toJson()`) to `Endpoints.pantry`.
  ///
  /// Returns the raw response body as `Map<String, dynamic>` for the repository
  /// layer to deserialize into a `PantryItem` domain model. The [dto] carries
  /// `ingridient` (spelling preserved verbatim from the backend `PantryIngridient`
  /// schema), `quantity`, `unit`, `location`, and `expirationDate`.
  ///
  /// Auth is automatic via the [DioClient] interceptor; throws `DioException` on
  /// network failure or a non-2xx response.
  Future<Map<String, dynamic>> createPantryItem(CreatePantryItemDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.pantry,
      data: dto.toJson(),
    );
    return response.data;
  }

  /// PATCHes the serialized [dto] to `${Endpoints.pantry}/${dto.id}`, the
  /// item-specific URL built from the base pantry endpoint plus the DTO's `id`.
  ///
  /// Returns the raw response body as `Map<String, dynamic>` for the repository
  /// layer to deserialize into a `PantryItem` domain model. The [dto] carries
  /// `id` plus the mutable fields (`location`, `quantity`, `expirationDate`); the
  /// embedded ingredient is fixed at creation and is not updated here.
  ///
  /// Auth is automatic via the [DioClient] interceptor; throws `DioException` on
  /// network failure or a non-2xx response.
  Future<Map<String, dynamic>> updatePantryItem(UpdatePantryItemDto dto) async {
    Response<dynamic> response = await _dio.patch(
      '${Endpoints.pantry}/${dto.id}',
      data: dto.toJson(),
    );
    return response.data;
  }

  /// Issues a DELETE to `${Endpoints.pantry}/$id`.
  ///
  /// Despite the soft-delete naming convention, the backend route `softDelete`
  /// currently calls `deleteOne()`, physically removing the record. Source:
  /// `backend/src/pantry/infrastructure/document/repositories/`
  /// `pantryIngridient.repository.ts:L119-L123`. This request therefore
  /// destructively removes the row from MongoDB; see `PRODUCTION_READINESS.md`
  /// for the production-readiness gap entry.
  ///
  /// Returns nothing meaningful (`Future<void>`). Auth is automatic via the
  /// [DioClient] interceptor; throws `DioException` on network failure or a
  /// non-2xx response.
  Future<void> deletePantryItem(String id) async {
    Response<dynamic> response = await _dio.delete('${Endpoints.pantry}/$id');
    return response.data;
  }
}
