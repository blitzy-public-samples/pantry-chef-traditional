import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/images.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            builder: (_, constarints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constarints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(Images.logo),
                    Column(
                      children: [
                        ActionButton(
                          text: AppLocalizations.of(context)!.signup,
                          onPress: () => Navigator.of(context).pushNamed(Navigation.singup),
                        ),
                        const SizedBox(height: 12),
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
