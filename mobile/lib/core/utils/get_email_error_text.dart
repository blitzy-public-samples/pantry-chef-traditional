import 'package:flutter/material.dart';
import 'package:pantry_chef/core/constants/error_message.dart';
import 'package:pantry_chef/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Maps the authentication [state] into a localized email error string,
/// resolving the message through `AppLocalizations` with the given [context].
///
/// Branches are evaluated in the following PRIORITY order and the first
/// matching message wins:
///
/// 1. Malformed email: returns the `emailWrongFormat` localized string when
///    `state.emailWrongFormat` is true.
///    Source: mobile/lib/core/utils/get_email_error_text.dart:L7-L9
/// 2. `ErrorMessage.emailAlreadyExists`: returns the `emailAlreadyExists`
///    localized string.
///    Source: mobile/lib/core/utils/get_email_error_text.dart:L10-L12
/// 3. `ErrorMessage.notFound`: returns the `wrongEmail` localized string.
///    Source: mobile/lib/core/utils/get_email_error_text.dart:L13-L15
///
/// Returns `null` when no email-specific message applies.
/// Source: mobile/lib/core/utils/get_email_error_text.dart:L16
String? getEmailErrorText(BuildContext context, AuthState state) {
  // Priority 1: malformed email format takes precedence.
  if (state.emailWrongFormat) {
    return AppLocalizations.of(context)!.emailWrongFormat;
  }
  // Priority 2: backend reports the email already exists.
  if (state.errorMessage == ErrorMessage.emailAlreadyExists) {
    return AppLocalizations.of(context)!.emailAlreadyExists;
  }
  // Priority 3: not-found maps to the wrong-email message.
  if (state.errorMessage == ErrorMessage.notFound) {
    return AppLocalizations.of(context)!.wrongEmail;
  }
  // Fallback: no email-specific message applies.
  return null;
}
