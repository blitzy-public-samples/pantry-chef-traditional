import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/constants/status_codes.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';

class DioClient {
  late final SharedPreferencesHelper _sharedPrefHelper;
  late final Dio _refreshDio;
  late final Dio dio;

  DioClient({required sharedPrefHelper}) {
    _sharedPrefHelper = sharedPrefHelper;
    _refreshDio = Dio();
    dio = Dio();
    _setupDio();
    _setupRefreshDio();
  }

  void _setupDio() {
    dio
      ..options.baseUrl = Endpoints.apiBaseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.headers = {
        'Content-Type': 'application/json; charset=utf-8',
      }
      ..interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          String? token = _sharedPrefHelper.accessToken;
          if (token != null) {
            options.headers.addAll({"Authorization": "Bearer $token"});
          }
          return handler.next(options);
        }, onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
          return handler.next((response));
        }, onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.response != null &&
              (e.response?.statusCode == StatusCodes.tokenExpired ||
                  e.response?.statusCode == StatusCodes.unauthorized)) {
            return _refreshToken(e, handler);
          }
          return handler.reject(e);
        }),
      );
  }

  void _setupRefreshDio() {
    _refreshDio
      ..options.baseUrl = Endpoints.apiBaseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.headers = {'Content-Type': 'application/json; charset=utf-8'}
      ..interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ),
      );
  }

  Future<void> _refreshToken(DioException e, ErrorInterceptorHandler handler) async {
    RequestOptions requestOptions = e.requestOptions;
    String? refreshToken = _sharedPrefHelper.refreshToken;
    if (refreshToken == null) {
      return handler.reject(e);
    }
    _refreshDio.options.headers["Authorization"] = 'Bearer $refreshToken';
    Response<Map<String, dynamic>> tokenResponse = await _refreshDio.post(
      Endpoints.refreshToken,
      queryParameters: {'token': refreshToken},
    );
    await _sharedPrefHelper.saveAccessToken(tokenResponse.data!['token']!);
    await _sharedPrefHelper.saveRefreshToken(tokenResponse.data!['refreshToken']!);
    final token = _sharedPrefHelper.accessToken;
    final opts = Options(method: requestOptions.method);

    dio.options.headers["Authorization"] = 'Bearer $token';
    final response = await dio.request(
      requestOptions.path,
      options: opts,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
    handler.resolve(response);
  }
}
