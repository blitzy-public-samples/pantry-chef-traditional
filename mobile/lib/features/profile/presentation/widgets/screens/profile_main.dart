import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:pantry_chef/features/profile/presentation/widgets/profile_navigation_item.dart';

class ProfileMain extends StatelessWidget {
  const ProfileMain({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const ProfileAvatar(),
                          const SizedBox(height: 12),
                          Text(
                            state.userProfile?.email ?? '',
                            style: context.theme.appTextTheme.regular16,
                          ),
                          const SizedBox(height: 48),
                          Divider(height: 0),
                          ProfileNavigationItem(
                            title: AppLocalizations.of(context)!.preferences,
                            page: Navigation.preferences,
                          ),
                          Divider(height: 0),
                          ProfileNavigationItem(
                            title: AppLocalizations.of(context)!.recipeFavorite,
                            page: Navigation.favoriteRecipes,
                          ),
                          Divider(height: 0),
                        ],
                      ),
                      ActionButton(
                        text: AppLocalizations.of(context)!.logout,
                        onPress: () {
                          context.read<ProfileBloc>().add(Logout(context: context));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
