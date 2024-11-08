part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthFormValueChanged extends AuthEvent {
  final String? email;
  final String? password;

  const AuthFormValueChanged({this.email, this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginActionSent extends AuthEvent {}

class SignupActionSend extends AuthEvent {}
