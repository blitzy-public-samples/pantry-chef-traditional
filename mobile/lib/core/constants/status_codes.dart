/// Non-instantiable static namespace cataloging HTTP/API response codes
/// used across network and error-handling flows.
///
/// DioClient checks [tokenExpired] (419) and [unauthorized] (401) on a
/// failed response to drive the token-refresh path
/// (Source: mobile/lib/core/utils/dio_client.dart:L44-L49). The private
/// constructor StatusCodes._() prevents instantiation.
///
/// Source: mobile/lib/core/constants/status_codes.dart:L1-L2
class StatusCodes {
  // Private constructor: prevents instantiation of the static namespace.
  StatusCodes._();

  //General
  /// ok = 200 (success). Source: ...:L5
  static const int ok = 200;
  /// created = 201 (resource created). Source: ...:L6
  static const int created = 201;

  /// badRequest = 400 (malformed request). Source: ...:L8
  static const int badRequest = 400;
  /// unauthorized = 401 (DioClient refresh trigger). Source: ...:L9
  static const int unauthorized = 401;
  /// notFound = 404 (resource not found). Source: ...:L10
  static const int notFound = 404;
  /// tokenExpired = 419 (non-standard; DioClient refresh). Source: ...:L11
  static const int tokenExpired = 419;
  /// unprocessableEntity = 422 (validation/duplicate errors). Source: ...:L12
  static const int unprocessableEntity = 422;
  /// tooManyRequests = 429 (rate limited). Source: ...:L13
  static const int tooManyRequests = 429;
  /// internalServerError = 500 (server error). Source: ...:L14
  static const int internalServerError = 500;
  /// serverBeingUpdated = 503 (service unavailable). Source: ...:L15
  static const int serverBeingUpdated = 503;
}
