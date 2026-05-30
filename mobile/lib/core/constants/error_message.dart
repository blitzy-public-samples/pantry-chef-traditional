/// Non-instantiable namespace of backend error-code STRING identifiers.
///
/// These constants are the textual error codes the backend returns inside the
/// body of an error response. They are intentionally distinct from the HTTP
/// integer status codes catalogued in `status_codes.dart` (`StatusCodes`):
/// this class holds the string identifiers, not numeric transport-level codes.
///
/// The values are stable backend contract identifiers and must match what the
/// backend sends verbatim; renaming a value would silently break the
/// error-handling flows that compare against it.
///
/// UI mappers such as `mobile/lib/core/utils/get_email_error_text.dart` consume
/// these constants to translate a raw backend error code into a localized,
/// user-facing message via `AppLocalizations`.
class ErrorMessage {
  ErrorMessage._();

  /// Backend error code returned when a login attempt fails due to a wrong
  /// password.
  ///
  /// Surfaced on the login screen as a localized wrong-password message via
  /// `AppLocalizations` (see `login.dart`, which maps it to `wrongPassword`).
  static const String incorrectPassword = 'incorrectPassword';

  /// Backend error code returned when an entity (user, recipe, etc.) cannot be
  /// found.
  ///
  /// During login this is also surfaced as a "wrong email" message rather than
  /// a distinct "user not found": the UI deliberately does not differentiate
  /// the two to avoid email-enumeration leaks. See
  /// `mobile/lib/core/utils/get_email_error_text.dart`, which maps it to the
  /// `wrongEmail` localization.
  static const String notFound = 'notFound';

  /// Backend error code returned during registration when the email address is
  /// already in use.
  ///
  /// Mapped by `mobile/lib/core/utils/get_email_error_text.dart` to the
  /// `emailAlreadyExists` localization and shown beneath the email field.
  static const String emailAlreadyExists = 'emailAlreadyExists';
}
