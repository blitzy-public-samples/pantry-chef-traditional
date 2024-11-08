part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final String email;
  final String password;
  final String? errorMessage;
  final bool success;
  final bool emailWrongFormat;
  final bool passwordToShort;
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
