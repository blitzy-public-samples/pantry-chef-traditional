/// Non-instantiable namespace of HTTP and custom backend status codes.
///
/// Centralizes the numeric response codes used by `DioClient` error handling
/// and feature-level response checks. Most values are standard HTTP status
/// codes per RFC 7231 / RFC 6585.
///
/// The one exception is `tokenExpired` (419), a custom backend status code that
/// is not part of standard HTTP. `DioClient` treats both `unauthorized` (401)
/// and `tokenExpired` (419) as triggers for the refresh-token flow.
class StatusCodes {
  StatusCodes._();

  //General
  /// Standard HTTP 200 OK. Returned by successful GET/PATCH/DELETE operations.
  static const int ok = 200;
  /// Standard HTTP 201 Created. Returned by POST endpoints that create
  /// resources (e.g., `POST /auth/email/register`, `POST /recipe`, `POST /pantry`).
  static const int created = 201;

  /// Standard HTTP 400 Bad Request. Returned when request validation fails
  /// (DTO validation, malformed JSON, etc.).
  static const int badRequest = 400;
  /// Standard HTTP 401 Unauthorized.
  ///
  /// Triggers the refresh-token flow in `DioClient`'s `onError` interceptor
  /// (see `mobile/lib/core/utils/dio_client.dart`).
  static const int unauthorized = 401;
  /// Standard HTTP 404 Not Found. Returned when a requested entity does not
  /// exist or has been soft-deleted.
  static const int notFound = 404;
  /// Custom backend status code (non-standard HTTP) meaning "JWT expired but
  /// otherwise well-formed".
  ///
  /// 419 is not defined by standard HTTP (RFC 7231 / RFC 6585); some Microsoft
  /// conventions use it as "Page Expired", but the PantryChef backend defines
  /// it specifically as an expired-but-well-formed JWT.
  ///
  /// `DioClient` treats both `unauthorized` (401) and `tokenExpired` (419) as
  /// triggers for the refresh-token flow. Production hardening should normalize
  /// this to standard 401 where possible; for now the mobile and backend
  /// contracts both rely on 419 specifically.
  static const int tokenExpired = 419;
  /// Standard HTTP 422 Unprocessable Entity. Returned when a request is
  /// syntactically valid but fails semantic validation (e.g., a referenced
  /// ingredient does not exist).
  static const int unprocessableEntity = 422;
  /// Standard HTTP 429 Too Many Requests. Returned when the client has been
  /// rate-limited.
  ///
  /// Note: rate limiting is not yet implemented in the backend (see
  /// `../../../../PRODUCTION_READINESS.md` § Security Hardening); this constant
  /// is reserved for the production rollout.
  static const int tooManyRequests = 429;
  /// Standard HTTP 500 Internal Server Error. Returned by unhandled backend
  /// exceptions.
  static const int internalServerError = 500;
  /// Standard HTTP 503 Service Unavailable. Returned by the backend during
  /// deploys or scheduled maintenance.
  static const int serverBeingUpdated = 503;
}
