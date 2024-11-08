import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_list.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/widgets/recipe_card.dart';

class FavoriteRecipes extends StatelessWidget {
  const FavoriteRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: getAppBarWidget(
        context,
        title: AppLocalizations.of(context)!.recipeFavorite,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CommonConstants.pagePadding, vertical: 24),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (contetx, state) {
              if (state.favoriteRecipes == null) {
                contetx.read<ProfileBloc>().add(FavoriteRecipesFetched());
                return ShimmerList(cardHeight: 200);
              }
              if (state.favoriteRecipes!.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 100,
                        color: context.theme.appColors.grey,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.favoriteRecipesEmptyMessage,
                        style: context.theme.appTextTheme.semiBold14.copyWith(
                          color: context.theme.appColors.grey,
                        ),
                      )
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.favoriteRecipes!.length,
                itemBuilder: (_, index) {
                  return RecipeCard(
                    item: state.favoriteRecipes![index],
                    isFavorite: true,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
