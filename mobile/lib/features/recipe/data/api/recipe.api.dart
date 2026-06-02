import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/data/dto/query_recipe.dto.dart';

/// Thin wrapper over the app's shared [Dio] HTTP client (resolved via
/// `getIt<DioClient>().dio`) that centralizes recipe endpoint
/// composition and returns raw backend payloads.
///
/// Performs no domain mapping or caching; the repository layer is
/// responsible for decoding responses into models.
class RecipeApi {
  // Shared Dio instance resolved from the service locator.
  late final Dio _dio;

  RecipeApi() {
    // Resolve the shared Dio client from the service locator.
    _dio = getIt<DioClient>().dio;
  }

  /// Issues `GET Endpoints.recipe` and returns the recipe list held
  /// in the response `data` envelope (`response.data['data']`).
  Future<List<dynamic>> getRecipeList() async {
    Response<dynamic> response = await _dio.get(
      Endpoints.recipe,
    );
    return response.data['data'];
  }

  /// Issues `GET ${Endpoints.recipe}/matches`, passing [filters] as
  /// `queryParameters` via `filters.toJson()`; returns `response.data`.
  Future<List<dynamic>> recipeMatching(RecipeFiltersDto filters) async {
    Response<dynamic> response = await _dio.get('${Endpoints.recipe}/matches', queryParameters: filters.toJson());
    return response.data;
  }

  /// Issues `GET ${Endpoints.recipe}/$id` for the recipe identified
  /// by [id]; returns `response.data`.
  Future<Map<String, dynamic>> getRecipeById(String id) async {
    Response<dynamic> response = await _dio.get('${Endpoints.recipe}/$id');
    return response.data;
  }

  /// Builds query params from `QueryRecipeDto(ids: ids).toJson()` for
  /// the given [ids], issues `GET Endpoints.recipe` with those params,
  /// and returns `response.data['data']`.
  Future<List<dynamic>> getFavoriteList(List<String> ids) async {
    final params = QueryRecipeDto(ids: ids).toJson();
    Response<dynamic> response = await _dio.get(
      Endpoints.recipe,
      queryParameters: params,
    );
    return response.data['data'];
  }
}
