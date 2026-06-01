part of 'auth_bloc.dart';

/// Immutable state for the login + signup screens.
///
/// Holds the current email/password input values, the latest DioException error message, and
/// boolean flags for success (navigate-home trigger), emailWrongFormat, passwordToShort, and
/// isFetching (loader overlay trigger). copyWith uses a Nullable<String> sentinel on the
/// errorMessage parameter to distinguish "set to null explicitly" from "leave unchanged".
class AuthState extends Equatable {
  /// Current email input value (defaults to empty string).
  final String email;
  /// Current password input value (defaults to empty string).
  final String password;
  /// Last DioException error mapped from response.data['errors']['email'|'password'], or null.
  final String? errorMessage;
  /// True after a successful login/signup; triggers Navigator.pushNamedAndRemoveUntil home.
  final bool success;
  /// True if the most recent submit failed regex validation; surfaced via getEmailErrorText.
  final bool emailWrongFormat;
  /// True if signup password length was < 6 at submit time. Field-name spelling preserved as-is.
  final bool passwordToShort;
  /// True while a login/signup request is in flight; toggles the loader_overlay UI.
  final bool isFetching;

  /// Creates an immutable state with optional initial values for every field.
  const AuthState({
    this.email = '',
    this.password = '',
    this.errorMessage,
    this.success = false,
    this.emailWrongFormat = false,
    this.passwordToShort = false,
    this.isFetching = false,
  });

  /// Equality props: all seven public fields.
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

  /// Returns a new AuthState with the supplied fields overridden.
  ///
  /// errorMessage uses a Nullable<String> wrapper: passing Nullable.value(null) explicitly resets
  /// the error, while passing null leaves the current value unchanged. This pattern lives in
  /// mobile/lib/core/utils/nullable_wrapper.dart.
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
