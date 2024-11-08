import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';

class IngredientApi {
  late final Dio _dio;

  IngredientApi() {
    _dio = getIt<DioClient>().dio;
  }

  Future<Map<String, dynamic>> getCategoriesAndUnits() async {
    Response<dynamic> response = await _dio.get(Endpoints.ingredientCreationData);
    return response.data;
  }

  Future<List<dynamic>> searchIngredient(SearchDto dto) async {
    Response<Map<String, dynamic>> response = await _dio.get(Endpoints.ingredient, queryParameters: dto.toJson());
    return response.data!['data'];
  }

  Future<Map<String, dynamic>> createIngredient(CreateIngredientDto dto) async {
    Response<dynamic> response = await _dio.post(Endpoints.ingredient, data: dto.toJson());
    return response.data;
  }

  Future<dynamic> processImage(XFile image) async {
    try {
      FormData formData = FormData();
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(image.path, filename: image.name)));
      final response = await _dio.post('${Endpoints.ai}/vision', data: formData);
      return response.data;
    } catch (err) {
      print(err);
      rethrow;
    }
  }
}
