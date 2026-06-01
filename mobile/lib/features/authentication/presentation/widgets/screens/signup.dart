import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/presentation/widgets/text_field_input.dart';
import 'package:pantry_chef/core/utils/get_email_error_text.dart';
import 'package:pantry_chef/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// Signup screen for the authentication flow.
///
/// Provides its own `AuthBloc` via `BlocProvider` and renders email and
/// password fields using the shared `TextFieldInput` widget. Dispatches
/// `SignupActionSend` (sic) on submit, navigates to `Navigation.home`
/// once `AuthState.success` becomes true, and shows a loader overlay
/// while `AuthState.isFetching` is true.
///
/// Source: .../signup.dart:L14
class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MultiBlocListener(
        listeners: [
          // On AuthState.success, navigates to Navigation.home and
          // clears the back stack via pushNamedAndRemoveUntil.
          // Source: .../signup.dart:L23
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => prev.success != curr.success,
            listener: (context, state) {
              if (state.success) {
                Navigator.of(context).pushNamedAndRemoveUntil(Navigation.home, (_) => false);
              }
            },
          ),
          // On AuthState.isFetching change, shows or hides the
          // loader overlay; requires a loader-overlay ancestor.
          // Source: .../signup.dart:L31
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
          appBar: getAppBarWidget(context, title: AppLocalizations.of(context)!.signup),
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
                            // buildWhen limits rebuilds to email,
                            // emailWrongFormat, and errorMessage. Caps
                            // at maxLength 50, validates via
                            // getEmailErrorText, and dispatches
                            // AuthFormValueChanged(email: value).
                            // Source: .../signup.dart:L61
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.email != curr.email ||
                                  prev.emailWrongFormat != curr.emailWrongFormat ||
                                  prev.errorMessage != curr.errorMessage,
                              builder: (context, state) {
                                return TextFieldInput(
                                  label: AppLocalizations.of(context)!.email,
                                  hintText: AppLocalizations.of(context)!.emailFormatHint,
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
                            // buildWhen limits rebuilds to password
                            // and passwordToShort. The passwordToShort
                            // flag drives errorText (shows passwordHint);
                            // caps at maxLength 10, dispatches
                            // AuthFormValueChanged(password: value).
                            // Source: .../signup.dart:L80
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.password != curr.password || prev.passwordToShort != curr.passwordToShort,
                              builder: (context, state) {
                                return TextFieldInput(
                                  label: AppLocalizations.of(context)!.password,
                                  hintText: AppLocalizations.of(context)!.passwordHint,
                                  errorText: state.passwordToShort ? AppLocalizations.of(context)!.passwordHint : null,
                                  maxLength: 10,
                                  required: true,
                                  onChanged: (String value) {
                                    context.read<AuthBloc>().add(AuthFormValueChanged(password: value));
                                  },
                                );
                              },
                            )
                          ],
                        ),
                        // Submit button. onPress stays null (disabled,
                        // greyed) until both email and password are
                        // non-empty; otherwise dispatches
                        // SignupActionSend() (sic) on the AuthBloc.
                        // Source: .../signup.dart:L98
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ActionButton(
                              text: AppLocalizations.of(context)!.signup,
                              onPress: state.email.trim() == '' || state.password.trim() == ''
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(SignupActionSend());
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
