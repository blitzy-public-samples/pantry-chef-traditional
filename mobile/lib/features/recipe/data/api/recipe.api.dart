import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/data/dto/query_recipe.dto.dart';

/// Dio API client for the backend `/api/v1/recipe` endpoint family.
///
/// Resolves the shared `Dio` instance via `getIt<DioClient>().dio`, so the
/// JWT bearer header is attached automatically by the `DioClient`'s
/// `InterceptorsWrapper` (see
/// [ARCHITECTURE.md](../../../../../../ARCHITECTURE.md) § JWT Authentication
/// Flow). All endpoints require backend `AuthGuard('jwt')`.
class RecipeApi {
  late final Dio _dio;

  /// Captures the shared Dio instance from the service locator at construction time.
  RecipeApi() {
    _dio = getIt<DioClient>().dio;
  }

  /// Returns the paginated recipe list payload's `data` array from
  /// `GET /api/v1/recipe`.
  ///
  /// Backend caps the page size at 50 regardless of the requested `limit`
  /// (see `mobile/lib/features/recipe/README.md` § API / Endpoint Reference).
  /// The wrapping envelope's `data` key is unwrapped here so callers receive
  /// the raw recipe list.
  Future<List<dynamic>> getRecipeList() async {
    Response<dynamic> response = await _dio.get(
      Endpoints.recipe,
    );
    return response.data['data'];
  }

  // NOTE: filters.toJson() always emits both flags, so default false sends
  // isQuickMake=false&isAlmostThere=false on the wire. The backend reads these via
  // @Query() as raw STRINGS, and the non-empty string "false" is truthy in JS.
  // FIXME: both-false therefore does NOT behave as "return all matches" server-side.
  // Document only; do not fix here (see README § Known Limitations and Implementation Gaps).
  /// Calls `GET /api/v1/recipe/matches` with `filters.toJson()` as query
  /// parameters and returns the response body verbatim.
  ///
  /// The returned list is sorted by `matchScore` descending on the server.
  /// See `mobile/lib/features/recipe/README.md` § Data Flows for the
  /// consumer flow and § Known Limitations and Implementation Gaps for the
  /// boolean-filter contract caveat, and
  /// [ARCHITECTURE.md](../../../../../../ARCHITECTURE.md) § Recipe Matching
  /// Pipeline for the server-side scoring algorithm.
  Future<List<dynamic>> recipeMatching(RecipeFiltersDto filters) async {
    Response<dynamic> response = await _dio.get('${Endpoints.recipe}/matches', queryParameters: filters.toJson());
    return response.data;
  }

  /// Calls `GET /api/v1/recipe/:id` and returns the single recipe document
  /// as the raw response body.
  Future<Map<String, dynamic>> getRecipeById(String id) async {
    Response<dynamic> response = await _dio.get('${Endpoints.recipe}/$id');
    return response.data;
  }

  /// Calls `GET /api/v1/recipe` with `QueryRecipeDto(ids: ids).toJson()` as
  /// query parameters and returns the `data` array.
  ///
  /// Used by the favorites flow to hydrate recipes by id list. Backend
  /// pagination cap of 50 still applies; callers expecting more must paginate.
  Future<List<dynamic>> getFavoriteList(List<String> ids) async {
    final params = QueryRecipeDto(ids: ids).toJson();
    Response<dynamic> response = await _dio.get(
      Endpoints.recipe,
      queryParameters: params,
    );
    return response.data['data'];
  }
}
