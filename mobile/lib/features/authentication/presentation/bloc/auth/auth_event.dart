part of 'auth_bloc.dart';

/// Base type for all authentication events dispatched to AuthBloc.
///
/// Sealed so the bloc's on<...> handlers can exhaustively match every subclass at compile time.
sealed class AuthEvent extends Equatable {
  /// Const default constructor for sealed subclasses to invoke via super().
  const AuthEvent();

  /// Empty equality props on the base event; concrete subclasses contribute their own.
  @override
  List<Object?> get props => [];
}

/// Emitted when the user mutates the email or password field on either the login or signup
/// screen. Either field may be null (meaning "unchanged") and the bloc preserves the prior
/// value via copyWith semantics.
class AuthFormValueChanged extends AuthEvent {
  /// New email value, or null if the email field was not touched in this dispatch.
  final String? email;
  /// New password value, or null if the password field was not touched in this dispatch.
  final String? password;

  /// Creates a form-value-changed event with optional email and password updates.
  const AuthFormValueChanged({this.email, this.password});

  /// Equality props: the email + password tuple.
  @override
  List<Object?> get props => [email, password];
}

/// Emitted when the user taps the "Login" submit button on the Login screen.
class LoginActionSent extends AuthEvent {}

/// Emitted when the user taps the "Signup" submit button on the Signup screen.
class SignupActionSend extends AuthEvent {}
