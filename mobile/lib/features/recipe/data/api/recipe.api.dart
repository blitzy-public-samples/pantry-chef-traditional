import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/data/dto/query_recipe.dto.dart';

class RecipeApi {
  late final Dio _dio;

  RecipeApi() {
    _dio = getIt<DioClient>().dio;
  }

  Future<List<dynamic>> getRecipeList() async {
    Response<dynamic> response = await _dio.get(
      Endpoints.recipe,
    );
    return response.data['data'];
  }

  Future<List<dynamic>> recipeMatching(RecipeFiltersDto filters) async {
    Response<dynamic> response = await _dio.get('${Endpoints.recipe}/matches', queryParameters: filters.toJson());
    return response.data;
  }

  Future<Map<String, dynamic>> getRecipeById(String id) async {
    Response<dynamic> response = await _dio.get('${Endpoints.recipe}/$id');
    return response.data;
  }

  Future<List<dynamic>> getFavoriteList(List<String> ids) async {
    final params = QueryRecipeDto(ids: ids).toJson();
    Response<dynamic> response = await _dio.get(
      Endpoints.recipe,
      queryParameters: params,
    );
    return response.data['data'];
  }
}
