import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/constants/status_codes.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';

/// Authenticated HTTP client wrapper around `Dio`.
///
/// Exposes the primary [dio] instance for all app API calls and keeps an
/// internal [_refreshDio] dedicated to token refresh.
///
class DioClient {
  // Provides persisted access and refresh tokens for requests.
  late final SharedPreferencesHelper _sharedPrefHelper;
  // Isolated Dio client used only for the token-refresh call.
  late final Dio _refreshDio;
  // Public authenticated client consumed by feature repositories.
  late final Dio dio;

  /// Creates the client from [sharedPrefHelper], constructs both `Dio`
  /// instances, then runs `_setupDio()` and `_setupRefreshDio()`.
  ///
  DioClient({required sharedPrefHelper}) {
    _sharedPrefHelper = sharedPrefHelper;
    _refreshDio = Dio();
    dio = Dio();
    _setupDio();
    _setupRefreshDio();
  }

  /// Configures [dio] with the base URL (`Endpoints.apiBaseUrl`), connect
  /// and receive timeouts, a JSON content-type header, and registers two
  /// interceptors: a `LogInterceptor` and an `InterceptorsWrapper`.
  ///
  void _setupDio() {
    dio
      ..options.baseUrl = Endpoints.apiBaseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.headers = {
        'Content-Type': 'application/json; charset=utf-8',
      }
      ..interceptors.add(
        // SECURITY NOTE: This `LogInterceptor` is added unconditionally
        // with `requestHeader: true`, so the `Authorization: Bearer
        // <token>` header is written to logs in ALL builds, including
        // release. Documented here, NOT fixed (additive-only task).
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          // onRequest attaches the bearer token from
          // _sharedPrefHelper.accessToken to [options] headers when present.
          String? token = _sharedPrefHelper.accessToken;
          if (token != null) {
            options.headers.addAll({"Authorization": "Bearer $token"});
          }
          return handler.next(options);
        }, onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
          return handler.next((response));
        }, onError: (DioException e, ErrorInterceptorHandler handler) async {
          // onError delegates to _refreshToken([e], [handler]) when the
          // status is StatusCodes.tokenExpired (419) or
          // StatusCodes.unauthorized (401); otherwise rejects via [handler].
          if (e.response != null &&
              (e.response?.statusCode == StatusCodes.tokenExpired ||
                  e.response?.statusCode == StatusCodes.unauthorized)) {
            return _refreshToken(e, handler);
          }
          return handler.reject(e);
        }),
      );
  }

  /// Configures the dedicated [_refreshDio] client with the base URL,
  /// connect/receive timeouts, a JSON content-type header, and its own
  /// `LogInterceptor`.
  ///
  void _setupRefreshDio() {
    _refreshDio
      ..options.baseUrl = Endpoints.apiBaseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.headers = {'Content-Type': 'application/json; charset=utf-8'}
      ..interceptors.add(
        // SECURITY NOTE: This `LogInterceptor` is also added
        // unconditionally with `requestHeader: true` on the refresh
        // client, so the `Authorization: Bearer <token>` header is
        // written to logs in ALL builds, including release. Documented
        // here, NOT fixed (additive-only task).
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ),
      );
  }

  /// Refreshes tokens then retries the failed request, in order:
  ///
  /// - Reads the stored refresh token; rejects the original error
  ///   via [handler] when it is null.
  /// - Sets the [_refreshDio] `Authorization` header to it.
  /// - POSTs `Endpoints.refreshToken`, passing the token as a query
  ///   parameter.
  /// - Persists the new access and refresh tokens.
  /// - Updates the main [dio] `Authorization` header.
  /// - Retries the original request and resolves it via [handler].
  ///
  /// [e] carries the failed request options and error context.
  ///
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
