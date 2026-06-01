part of 'auth_bloc.dart';

/// Base type for all auth events; carries no payload (empty `props`).
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Carries email/password edits from the form into the bloc.
class AuthFormValueChanged extends AuthEvent {
  /// Nullable email value the bloc uses to update `AuthState`.
  final String? email;
  /// Nullable password value the bloc uses to update `AuthState`.
  final String? password;

  const AuthFormValueChanged({this.email, this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Requests a login with the current form state.
class LoginActionSent extends AuthEvent {}

/// Requests a signup with the current form state.
class SignupActionSend extends AuthEvent {}
