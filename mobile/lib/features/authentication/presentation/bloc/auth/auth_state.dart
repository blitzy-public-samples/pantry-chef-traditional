part of 'auth_bloc.dart';

/// Immutable snapshot of the authentication form and flow.
///
/// `AuthBloc` consumes and emits this state to drive the login and signup
/// screens: it holds the current form input, validation flags, the in-flight
/// indicator, a server/validation error message, and the success flag.
class AuthState extends Equatable {
  /// Current email input value; defaults to an empty string.
  final String email;
  /// Current password input value; defaults to an empty string.
  final String password;
  /// Nullable server or validation error to surface, or null.
  final String? errorMessage;
  /// True once a login or signup request succeeds.
  final bool success;
  /// True when the email fails the `RegExps.email` pattern.
  final bool emailWrongFormat;
  /// True when the password length is less than 6 characters.
  final bool passwordToShort;
  /// True while an authentication request is in flight.
  final bool isFetching;

  const AuthState({
    this.email = '',
    this.password = '',
    this.errorMessage,
    this.success = false,
    this.emailWrongFormat = false,
    this.passwordToShort = false,
    this.isFetching = false,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        errorMessage,
        success,
        emailWrongFormat,
        passwordToShort,
        isFetching,
      ];

  /// Returns a copy of this state with the provided fields replaced.
  ///
  /// Each parameter defaults to `null` and, when omitted, leaves the
  /// corresponding field unchanged: [email], [password], [success],
  /// [emailWrongFormat], [passwordToShort], and [isFetching] fall back to
  /// the current value.
  ///
  /// [errorMessage] is wrapped in `Nullable<String>` so callers can tell
  /// "leave unchanged" (pass nothing) apart from an explicit set-or-null
  /// reset (pass `Nullable.value(...)`, including `Nullable.value(null)`).
  AuthState copyWith({
    final String? email,
    final String? password,
    final Nullable<String>? errorMessage,
    final bool? success,
    final bool? emailWrongFormat,
    final bool? passwordToShort,
    final bool? isFetching,
  }) =>
      AuthState(
        email: email ?? this.email,
        password: password ?? this.password,
        errorMessage: errorMessage != null ? errorMessage.value : this.errorMessage,
        success: success ?? this.success,
        emailWrongFormat: emailWrongFormat ?? this.emailWrongFormat,
        passwordToShort: passwordToShort ?? this.passwordToShort,
        isFetching: isFetching ?? this.isFetching,
      );
}
