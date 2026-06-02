import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/error_message.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/presentation/widgets/text_field_input.dart';
import 'package:pantry_chef/core/utils/get_email_error_text.dart';
import 'package:pantry_chef/features/authentication/presentation/bloc/auth/auth_bloc.dart';

/// Login screen for the authentication flow.
///
/// Provides its own `AuthBloc` via `BlocProvider` and renders email and
/// password fields built on the shared `TextFieldInput` widget. Dispatches
/// `LoginActionSent` on submit, navigates to `Navigation.home` once
/// `AuthState.success` becomes true, and toggles a loader overlay while
/// `AuthState.isFetching` is true.
///
class Login extends StatelessWidget {
  const Login({super.key});

  /// Builds the login screen for the given [context].
  ///
  /// Provides an [AuthBloc] and renders the email and password fields;
  /// dispatches `LoginActionSent` on submit, navigates to
  /// [Navigation.home] on success, and overlays a loader while fetching.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MultiBlocListener(
        listeners: [
          // On success, clears the entire back stack via
          // pushNamedAndRemoveUntil so the user cannot return to login.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => prev.success != curr.success,
            listener: (context, state) {
              if (state.success) {
                Navigator.of(context).pushNamedAndRemoveUntil(Navigation.home, (_) => false);
              }
            },
          ),
          // Toggles the loader overlay from `state.isFetching`;
          // requires a loader-overlay ancestor above this widget.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => prev.isFetching != curr.isFetching,
            listener: (context, state) {
              if (state.isFetching) {
                context.loaderOverlay.show();
              } else {
                context.loaderOverlay.hide();
              }
            },
          ),
        ],
        child: PlatformScaffold(
          appBar: getAppBarWidget(context, title: AppLocalizations.of(context)!.login),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: CommonConstants.pagePadding,
                right: CommonConstants.pagePadding,
                top: 50,
                bottom: 24,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            // buildWhen rebuilds only on email,
                            // errorMessage or emailWrongFormat changes.
                            // Caps input at maxLength 50, shows errors via
                            // getEmailErrorText, and dispatches
                            // AuthFormValueChanged(email: ...) on change.
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.email != curr.email ||
                                  prev.errorMessage != curr.errorMessage ||
                                  prev.emailWrongFormat != curr.emailWrongFormat,
                              builder: (context, state) {
                                return TextFieldInput(
                                  label: AppLocalizations.of(context)!.email,
                                  maxLength: 50,
                                  errorText: getEmailErrorText(context, state),
                                  required: true,
                                  onChanged: (String value) {
                                    context.read<AuthBloc>().add(AuthFormValueChanged(email: value));
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // buildWhen rebuilds only on password or
                            // errorMessage changes. Maps
                            // ErrorMessage.incorrectPassword to localized
                            // wrongPassword. Caps input at maxLength 10 and
                            // dispatches AuthFormValueChanged(password: ...).
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.password != curr.password || prev.errorMessage != curr.errorMessage,
                              builder: (context, state) {
                                return TextFieldInput(
                                  label: AppLocalizations.of(context)!.password,
                                  required: true,
                                  errorText: state.errorMessage == ErrorMessage.incorrectPassword
                                      ? AppLocalizations.of(context)!.wrongPassword
                                      : null,
                                  maxLength: 10,
                                  onChanged: (String value) {
                                    context.read<AuthBloc>().add(AuthFormValueChanged(password: value));
                                  },
                                );
                              },
                            )
                          ],
                        ),
                        // ActionButton stays disabled (onPress null)
                        // until both email and password are non-empty,
                        // then dispatches LoginActionSent() on press.
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ActionButton(
                              text: AppLocalizations.of(context)!.login,
                              onPress: state.email.trim() == '' || state.password.trim() == ''
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(LoginActionSent());
                                    },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
