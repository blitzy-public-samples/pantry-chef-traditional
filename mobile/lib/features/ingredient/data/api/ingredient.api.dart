import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';

/// Low-level remote adapter that centralizes all ingredient and AI HTTP
/// calls for the ingredient feature.
///
/// Does not create its own HTTP client: it reuses the shared, pre-configured
/// [DioClient] resolved from the service locator (`getIt<DioClient>().dio`,
/// see the constructor below), so interceptors, base options, and auth
/// headers are managed externally.
class IngredientApi {
  // Shared Dio instance obtained from the [DioClient]; transport
  // configuration (base URL, interceptors, auth) lives elsewhere.
  late final Dio _dio;

  IngredientApi() {
    // Resolve the shared, pre-configured Dio from the service locator.
    _dio = getIt<DioClient>().dio;
  }

  /// Performs `GET Endpoints.ingredientCreationData`
  /// (`/api/ingredient/creation-data`) and returns the decoded response
  /// body as `Map<String, dynamic>`: the categories and units reference
  /// metadata consumed by the add-ingredient form.
  ///
  /// Mobile endpoints use `/api/<resource>` with no `/v1/` segment.
  Future<Map<String, dynamic>> getCategoriesAndUnits() async {
    Response<dynamic> response = await _dio.get(Endpoints.ingredientCreationData);
    return response.data;
  }

  /// Performs `GET Endpoints.ingredient` (`/api/ingredient`) passing
  /// `[dto].toJson()` (the `query`/`page`/`limit`/`sort` search criteria)
  /// as `queryParameters`, and returns the nested `response.data!['data']`
  /// results array.
  Future<List<dynamic>> searchIngredient(SearchDto dto) async {
    Response<Map<String, dynamic>> response = await _dio.get(Endpoints.ingredient, queryParameters: dto.toJson());
    return response.data!['data'];
  }

  /// Performs `POST Endpoints.ingredient` (`/api/ingredient`) with
  /// `[dto].toJson()` as the request body and returns the raw response
  /// body as `Map<String, dynamic>`.
  Future<Map<String, dynamic>> createIngredient(CreateIngredientDto dto) async {
    Response<dynamic> response = await _dio.post(Endpoints.ingredient, data: dto.toJson());
    return response.data;
  }

  /// Builds a multipart `FormData` payload that attaches [image] under
  /// the `image` field, via
  /// `MultipartFile.fromFile(image.path, filename: image.name)`.
  ///
  /// POSTs the payload to `'${Endpoints.ai}/vision'` (`/api/ai/vision`)
  /// for AI/vision processing and returns the response body. Exceptions
  /// are logged then rethrown, so failures propagate unchanged.
  Future<dynamic> processImage(XFile image) async {
    try {
      FormData formData = FormData();
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(image.path, filename: image.name)));
      final response = await _dio.post('${Endpoints.ai}/vision', data: formData);
      return response.data;
    } catch (err) {
      // KNOWN ISSUE: print(err) logs to stdout and violates the elevated
      // avoid_print lint; preserved as-is per the additive-only constraint.
      print(err);
      rethrow;
    }
  }
}
