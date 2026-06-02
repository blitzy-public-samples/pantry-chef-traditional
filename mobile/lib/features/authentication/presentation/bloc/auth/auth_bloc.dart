import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/core/constants/status_codes.dart';
import 'package:pantry_chef/core/utils/nullable_wrapper.dart';
import 'package:pantry_chef/core/utils/reg_exp.dart';
import 'package:pantry_chef/features/authentication/data/dto/auth.dto.dart';
import 'package:pantry_chef/features/authentication/domain/usecases/login.usecase.dart';
import 'package:pantry_chef/features/authentication/domain/usecases/signup.usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Manages authentication form state and orchestrates the login and
/// signup flows for the login and signup screens.
///
/// Handles three events:
/// * [AuthFormValueChanged] updates the entered email and password and
///   clears any prior validation flags.
/// * [LoginActionSent] validates the email and runs [LoginUsecase].
/// * [SignupActionSend] validates the email and password length and runs
///   [SignupUsecase].
///
/// Emits [AuthState] updates that the login and signup screens observe.
/// Seeded with a default `AuthState()` on construction.
///
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState()) {
    // Updates email/password in state from the event and clears prior
    // errors/flags via copyWith: errorMessage reset with
    // const Nullable.value(null), emailWrongFormat=false,
    // passwordToShort=false.
    on<AuthFormValueChanged>((event, emit) {
      emit(
        state.copyWith(
          email: event.email,
          password: event.password,
          errorMessage: const Nullable.value(null),
          emailWrongFormat: false,
          passwordToShort: false,
        ),
      );
    });

    // Handles a login submission. Validates the email format, then runs
    // LoginUsecase with the trimmed credentials; maps a 422 response to
    // an inline errorMessage and always clears the fetching flag.
    on<LoginActionSent>((_, emit) async {
      // Reject an invalid email up front via RegExps.email and flag
      // emailWrongFormat without contacting the server.
      if (!RegExps.email.hasMatch(state.email)) {
        emit(state.copyWith(emailWrongFormat: true));
        return;
      }
      // Enter the loading state while the request is in flight.
      emit(state.copyWith(isFetching: true));
      // Build the login use case (calls the repo and stores tokens).
      LoginUsecase useCase = LoginUsecase();
      try {
        // Run login with trimmed email/password; emit success on 2xx.
        await useCase(AuthDto(email: state.email.trim(), password: state.password.trim()));
        emit(state.copyWith(success: true));
      } on DioException catch (err) {
        // On 422 (unprocessable entity) surface the server's email or
        // password error message into errorMessage via Nullable.value.
        if (err.response?.statusCode == StatusCodes.unprocessableEntity) {
          emit(
            state.copyWith(
              errorMessage: Nullable.value(
                err.response?.data['errors']['email'] ?? err.response?.data['errors']['password'],
              ),
            ),
          );
        }
      // Always clear the fetching flag once the request settles.
      } finally {
        emit(state.copyWith(isFetching: false));
      }
    });

    // Handles a signup submission. Validates the email format and
    // enforces a minimum password length before running SignupUsecase;
    // maps a DioException email error into errorMessage.
    // Note: the SignupActionSend event name is misspelled (sic) and is
    // kept as-is as a stable identifier.
    on<SignupActionSend>((_, emit) async {
      // Reject an invalid email up front, flagging emailWrongFormat.
      if (!RegExps.email.hasMatch(state.email)) {
        emit(state.copyWith(emailWrongFormat: true));
        return;
      }
      // Require at least 6 characters; otherwise flag passwordToShort.
      if (state.password.length < 6) {
        emit(state.copyWith(passwordToShort: true));
        return;
      }
      // Build the signup use case (calls the repo and stores tokens).
      SignupUsecase useCase = SignupUsecase();
      try {
        // Run signup with trimmed email/password; emit success on 2xx.
        await useCase(AuthDto(email: state.email.trim(), password: state.password.trim()));
        emit(state.copyWith(success: true));
      // Map a server email error into errorMessage via Nullable.value.
      } on DioException catch (err) {
        emit(state.copyWith(errorMessage: Nullable.value(err.response?.data['errors']['email'])));
      }
    });
  }
}
