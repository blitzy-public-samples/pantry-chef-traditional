/// Non-instantiable static namespace cataloging HTTP/API response codes
/// used across network and error-handling flows.
///
/// DioClient checks [tokenExpired] (419) and [unauthorized] (401) on a
/// failed response to drive the token-refresh path
/// (Source: mobile/lib/core/utils/dio_client.dart:L65-L70). The private
/// constructor StatusCodes._() prevents instantiation.
///
class StatusCodes {
  // Private constructor: prevents instantiation of the static namespace.
  StatusCodes._();

  //General
  /// ok = 200 (success).
  static const int ok = 200;
  /// created = 201 (resource created).
  static const int created = 201;

  /// badRequest = 400 (malformed request).
  static const int badRequest = 400;
  /// unauthorized = 401 (DioClient refresh trigger).
  static const int unauthorized = 401;
  /// notFound = 404 (resource not found).
  static const int notFound = 404;
  /// tokenExpired = 419 (non-standard; DioClient refresh).
  static const int tokenExpired = 419;
  /// unprocessableEntity = 422 (validation/duplicate errors).
  static const int unprocessableEntity = 422;
  /// tooManyRequests = 429 (rate limited).
  static const int tooManyRequests = 429;
  /// internalServerError = 500 (server error).
  static const int internalServerError = 500;
  /// serverBeingUpdated = 503 (service unavailable).
  static const int serverBeingUpdated = 503;
}
