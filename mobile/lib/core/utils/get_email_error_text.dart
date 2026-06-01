import 'package:flutter/material.dart';
import 'package:pantry_chef/core/constants/error_message.dart';
import 'package:pantry_chef/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Maps an authentication [AuthState] into a localized email-input error
/// message suitable for a `TextField.decoration.errorText`. It is the canonical
/// place to translate backend auth errors into UI text for the email field of
/// the login and signup forms.
///
/// Mapping priority (sequential `if`s — the first match wins):
/// 1. `state.emailWrongFormat == true` → localized "Wrong email format".
/// 2. `state.errorMessage == ErrorMessage.emailAlreadyExists` → localized
///    "Email already exists".
/// 3. `state.errorMessage == ErrorMessage.notFound` → localized "Wrong email".
///    The backend returns `notFound` for both "user does not exist" and "wrong
///    email" during login to prevent email-enumeration attacks; the mobile UI
///    deliberately surfaces it as "Wrong email".
/// 4. Any other state → `null` (no email-specific error to display).
///
/// [context] resolves localized strings via `AppLocalizations.of`; [state] is
/// the current [AuthState] from the authentication BLoC. Returns `null` when no
/// email-specific error applies (e.g. `incorrectPassword`, success or fetching
/// states). Typically consumed inline as the `errorText` of a `TextField`
/// within `BlocBuilder<AuthBloc, AuthState>` widgets in the authentication feature.
String? getEmailErrorText(BuildContext context, AuthState state) {
  if (state.emailWrongFormat) {
    return AppLocalizations.of(context)!.emailWrongFormat;
  }
  if (state.errorMessage == ErrorMessage.emailAlreadyExists) {
    return AppLocalizations.of(context)!.emailAlreadyExists;
  }
  if (state.errorMessage == ErrorMessage.notFound) {
    return AppLocalizations.of(context)!.wrongEmail;
  }
  return null;
}
