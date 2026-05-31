/// Non-instantiable static namespace of stable string error identifiers.
///
/// Used across auth, validation, and UI-state mapping. These are
/// app-internal identifier strings, not user-facing copy; the matching
/// localized text is produced elsewhere by `get_email_error_text.dart`
/// together with `AppLocalizations`. The private constructor
/// `ErrorMessage._()` prevents instantiation.
///
/// Source: mobile/lib/core/constants/error_message.dart:L1-L2
class ErrorMessage {
  // Private constructor: blocks instantiation of this static namespace.
  ErrorMessage._();

  /// Error id 'incorrectPassword' for a wrong password.
  /// Source: mobile/lib/core/constants/error_message.dart:L4
  static const String incorrectPassword = 'incorrectPassword';
  /// Error id 'notFound' (e.g., account or email not found).
  /// Source: mobile/lib/core/constants/error_message.dart:L5
  static const String notFound = 'notFound';
  /// Error id 'emailAlreadyExists' for a duplicate-email signup.
  /// Source: mobile/lib/core/constants/error_message.dart:L6
  static const String emailAlreadyExists = 'emailAlreadyExists';
}
