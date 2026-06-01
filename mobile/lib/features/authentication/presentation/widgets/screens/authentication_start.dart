import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/images.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Landing screen of the authentication flow.
///
/// Displays the app logo via `Image.asset(Images.logo)` and presents two
/// call-to-action buttons: the first routes to the signup screen and the
/// second to the login screen. Uses a responsive layout
/// (`Padding` -> `LayoutBuilder` -> `ConstrainedBox` -> `Column` with
/// `MainAxisAlignment.spaceBetween`) so the logo and buttons stay spaced
/// across device sizes.
///
/// Source: .../authentication_start.dart:L10
class AuthenticationStart extends StatelessWidget {
  const AuthenticationStart({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: CommonConstants.pagePadding,
            right: CommonConstants.pagePadding,
            top: 50,
            bottom: 24,
          ),
          child: LayoutBuilder(
            // `constarints` (sic) is a misspelled local variable name;
            // preserved intentionally and never renamed.
            builder: (_, constarints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constarints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(Images.logo),
                    Column(
                      children: [
                        // Signup button. Routes via the misspelled route
                        // `Navigation.singup` (sic), preserved intentionally;
                        // never rename or correct.
                        // Source: mobile/lib/core/constants/navigation.dart:L6
                        ActionButton(
                          text: AppLocalizations.of(context)!.signup,
                          onPress: () => Navigator.of(context).pushNamed(Navigation.singup),
                        ),
                        const SizedBox(height: 12),
                        // Login button: outlined style (`outline: true`)
                        // with a theme-driven text color
                        // (`context.theme.appColors.black`); routes to the
                        // login screen via `Navigation.login`.
                        ActionButton(
                          text: AppLocalizations.of(context)!.login,
                          textColor: context.theme.appColors.black,
                          outline: true,
                          onPress: () => Navigator.of(context).pushNamed(Navigation.login),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
