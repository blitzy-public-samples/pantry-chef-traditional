import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/widgets/recipe_card.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecipeMain extends StatefulWidget {
  const RecipeMain({super.key});

  @override
  State<RecipeMain> createState() => _RecipeMainState();
}

class _RecipeMainState extends State<RecipeMain> {
  @override
  void initState() {
    RecipeBloc bloc = context.read<RecipeBloc>();
    if (bloc.state.items == null) {
      context.read<RecipeBloc>().add(RecipeMatching());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (prev, curr) => prev.userProfile != curr.userProfile,
        builder: (context, profileState) {
          return BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, state) {
              if (state.isFetching || state.items == null) {
                return ShimmerList(cardHeight: 200);
              }
              if (state.items!.isEmpty) {
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
                        AppLocalizations.of(context)!.recipeEmptyMessage,
                        style: context.theme.appTextTheme.semiBold14.copyWith(
                          color: context.theme.appColors.grey,
                        ),
                      )
                    ],
                  ),
                );
              }
              final favoriteList = profileState.userProfile?.favoriteRecipes ?? [];
              return RefreshIndicator.adaptive(
                color: context.theme.appColors.green,
                onRefresh: () async => context.read<RecipeBloc>().add(RecipeMatching()),
                child: ListView.builder(
                    itemCount: state.items!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = state.items![index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: RecipeCard(
                          item: state.items![index],
                          isFavorite: favoriteList.any((el) => el == item.id),
                        ),
                      );
                    }),
              );
            },
          );
        },
      ),
    );
  }
}
