import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/pantry/data/dto/index.dart';

class PantryApi {
  late final Dio _dio;

  PantryApi() {
    _dio = getIt<DioClient>().dio;
  }

  Future<List<dynamic>> fetchPantryItems() async {
    Response<dynamic> response = await _dio.get(Endpoints.pantry);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> createPantryItem(CreatePantryItemDto dto) async {
    Response<dynamic> response = await _dio.post(
      Endpoints.pantry,
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updatePantryItem(UpdatePantryItemDto dto) async {
    Response<dynamic> response = await _dio.patch(
      '${Endpoints.pantry}/${dto.id}',
      data: dto.toJson(),
    );
    return response.data;
  }

  Future<void> deletePantryItem(String id) async {
    Response<dynamic> response = await _dio.delete('${Endpoints.pantry}/$id');
    return response.data;
  }
}
