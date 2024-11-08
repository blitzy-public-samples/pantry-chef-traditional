import 'package:flutter/material.dart';
import 'package:pantry_chef/core/constants/error_message.dart';
import 'package:pantry_chef/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
