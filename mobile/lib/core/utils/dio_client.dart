import 'package:dio/dio.dart';
import 'package:pantry_chef/core/constants/endpoints.dart';
import 'package:pantry_chef/core/constants/status_codes.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';

/// Central authenticated HTTP client for the PantryChef mobile app.
///
/// Maintains TWO [Dio] instances to keep the token-refresh cycle isolated:
/// - The public [dio] field is the primary authenticated client carrying the
///   full interceptor chain: [LogInterceptor] + JWT bearer injection +
///   401/419 refresh handling.
/// - The private `_refreshDio` is a separate instance used ONLY to perform the
///   token-refresh request. It has no JWT interceptor, so a refresh call never
///   itself triggers another refresh (preventing infinite recursion).
///
/// On a 401 (`StatusCodes.unauthorized`) or 419 (`StatusCodes.tokenExpired`,
/// a custom non-standard backend code) response from the primary [dio], the
/// error interceptor invokes `_refreshToken`, which uses `_refreshDio` to POST
/// the persisted refresh token to `Endpoints.refreshToken`, persists the new
/// access and refresh tokens via [SharedPreferencesHelper], and replays the
/// original request transparently.
///
/// Source: `mobile/lib/core/utils/dio_client.dart:L6-L98`. See
/// [ARCHITECTURE.md](../../../../ARCHITECTURE.md) § JWT Authentication Flow for
/// the full end-to-end request path. Typically resolved via GetIt:
/// `getIt<DioClient>().dio.<method>(...)` — registered in
/// `mobile/lib/core/utils/service_locator.dart:L13-L14`.
class DioClient {
  late final SharedPreferencesHelper _sharedPrefHelper;
  late final Dio _refreshDio;
  /// The authenticated HTTP client to use for all feature API calls.
  ///
  /// `Authorization: Bearer <token>` is auto-attached on every outbound request
  /// via the interceptor chain (only when an access token is persisted). On a
  /// 401/419 response the chain transparently refreshes the token and retries
  /// the original request. Configured with base URL `Endpoints.apiBaseUrl` and
  /// timeouts `Endpoints.connectionTimeout` (30s) and `Endpoints.receiveTimeout`
  /// (15s).
  late final Dio dio;

  /// Constructs the client, stores the [sharedPrefHelper] reference, and
  /// initializes BOTH Dio instances.
  ///
  /// Invokes private `_setupDio()` (primary authenticated client) and
  /// `_setupRefreshDio()` (refresh-only client) to wire up base URLs, timeouts,
  /// and interceptors. [sharedPrefHelper] is the [SharedPreferencesHelper] the
  /// interceptor chain reads JWT access and refresh tokens from.
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
        // TODO(prod): LogInterceptor logs full request/response including
        // Authorization: Bearer headers. Gate behind kDebugMode before release.
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ),
      )
      ..interceptors.add(
        // NOTE: JWT bearer is attached on every outbound request if accessToken is non-null.
        // On 401/419 the onError handler triggers _refreshToken().
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
        // TODO(prod): LogInterceptor on _refreshDio also leaks bearer tokens.
        // Gate behind kDebugMode before release.
        LogInterceptor(
          request: true,
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ),
      );
  }

  // TODO(prod): No concurrency lock. If multiple in-flight requests receive 401
  // simultaneously, parallel /auth/refresh calls may be issued. Implement a
  // single-flight semaphore.
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
