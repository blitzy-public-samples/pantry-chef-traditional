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

/// State machine driving the login and signup screens.
///
/// Handles three events: AuthFormValueChanged (form input mutation), LoginActionSent (submit
/// login), and SignupActionSend (submit signup). Validates email via RegExps.email and signup
/// password length (>= 6) before dispatching the use case. Catches DioException with status
/// 422 (StatusCodes.unprocessableEntity) and maps field errors from response.data['errors']
/// into AuthState.errorMessage via the Nullable<String> sentinel wrapper.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Initializes the bloc with a default AuthState() and registers the three event handlers.
  AuthBloc() : super(AuthState()) {
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

    on<LoginActionSent>((_, emit) async {
      if (!RegExps.email.hasMatch(state.email)) {
        emit(state.copyWith(emailWrongFormat: true));
        return;
      }
      emit(state.copyWith(isFetching: true));
      LoginUsecase useCase = LoginUsecase();
      try {
        await useCase(AuthDto(email: state.email.trim(), password: state.password.trim()));
        emit(state.copyWith(success: true));
      } on DioException catch (err) {
        if (err.response?.statusCode == StatusCodes.unprocessableEntity) {
          emit(
            state.copyWith(
              errorMessage: Nullable.value(
                err.response?.data['errors']['email'] ?? err.response?.data['errors']['password'],
              ),
            ),
          );
        }
      } finally {
        emit(state.copyWith(isFetching: false));
      }
    });

    on<SignupActionSend>((_, emit) async {
      if (!RegExps.email.hasMatch(state.email)) {
        emit(state.copyWith(emailWrongFormat: true));
        return;
      }
      if (state.password.length < 6) {
        emit(state.copyWith(passwordToShort: true));
        return;
      }
      SignupUsecase useCase = SignupUsecase();
      try {
        await useCase(AuthDto(email: state.email.trim(), password: state.password.trim()));
        emit(state.copyWith(success: true));
      } on DioException catch (err) {
        emit(state.copyWith(errorMessage: Nullable.value(err.response?.data['errors']['email'])));
      }
    });
  }
}
