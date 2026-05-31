import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';

/// Dio-based HTTP client for the ingredient feature's backend endpoints.
///
/// Resolves the shared [Dio] instance from `getIt<DioClient>().dio` so the
/// configured JWT interceptor (see `mobile/lib/core/utils/dio_client.dart`)
/// is applied to every request. The class is intentionally lightweight and
/// stateless; instances may be created per call without retaining transport
/// state. All methods return raw JSON payloads — domain mapping is performed
/// by `IngredientRepositoryImpl` in the sibling `repositories/` folder.
class IngredientApi {
  late final Dio _dio;

  /// Creates a new [IngredientApi] and resolves the shared [Dio] client.
  ///
  /// The Dio instance is obtained via `getIt<DioClient>().dio` and therefore
  /// inherits the application-wide base URL, headers, and interceptors.
  IngredientApi() {
    _dio = getIt<DioClient>().dio;
  }

  /// Fetches the categories and units reference data used by the add-ingredient
  /// form.
  ///
  /// Sends a GET request to `Endpoints.ingredientCreationData`
  /// (`/api/v1/ingredient/creation-data` on the backend). Returns the raw JSON
  /// map containing `categories` and `units` arrays; `IngredientRepositoryImpl`
  /// is responsible for mapping the result into an [IngredientAddData].
  Future<Map<String, dynamic>> getCategoriesAndUnits() async {
    Response<dynamic> response = await _dio.get(Endpoints.ingredientCreationData);
    return response.data;
  }

  /// Performs a paginated ingredient search against the backend.
  ///
  /// Sends a GET request to `Endpoints.ingredient` (`/api/v1/ingredient`) with
  /// `dto.toJson()` as `queryParameters` (page, limit, search, order). Returns
  /// the inner `data` array from the paginated envelope (`response.data!['data']`).
  /// The caller is responsible for mapping each element to an `Ingredient`.
  Future<List<dynamic>> searchIngredient(SearchDto dto) async {
    Response<Map<String, dynamic>> response = await _dio.get(Endpoints.ingredient, queryParameters: dto.toJson());
    return response.data!['data'];
  }

  /// Creates a new ingredient by POSTing a serialized [CreateIngredientDto].
  ///
  /// Sends a POST request to `Endpoints.ingredient` (`/api/v1/ingredient`) with
  /// `dto.toJson()` as the body. Returns the raw JSON of the persisted record;
  /// the backend response field naming follows the `Ingridient` schema spelling
  /// preserved verbatim from the backend `IngridientSchemaClass`. The caller is
  /// responsible for mapping the result into an `Ingredient` domain model.
  Future<Map<String, dynamic>> createIngredient(CreateIngredientDto dto) async {
    Response<dynamic> response = await _dio.post(Endpoints.ingredient, data: dto.toJson());
    return response.data;
  }

  /// Uploads a captured image to the backend AI vision endpoint for ingredient
  /// recognition.
  ///
  /// Builds a multipart `FormData` payload with the file attached under the form
  /// field name `'image'` (using `MultipartFile.fromFile(image.path,
  /// filename: image.name)`) and POSTs it to `'${Endpoints.ai}/vision'` which
  /// resolves to `/api/ai/vision` on the backend. The backend AI endpoint has
  /// **no JWT guard** at the time of writing (see
  /// `../../../../../backend/src/ai/README.md`). On any thrown error the message
  /// is printed and the original exception is rethrown so that `CameraBloc`
  /// can emit `ImageProcessingError`. The successful response may be `{}` when
  /// Google Cloud Vision returns no usable label — callers that map the result
  /// via `Ingredient.fromJson` should be prepared to catch the resulting error.
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
