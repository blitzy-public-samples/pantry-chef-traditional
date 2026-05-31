import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/widgets/recipe_card.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// `StatefulWidget` rendering the main recipe list / matches screen.
///
/// Wraps the body in a `PlatformScaffold`, dispatches `RecipeMatching()` on
/// `initState` when `RecipeBloc.state.items` is null (the matches-first UX
/// entry point), and exposes a `RefreshIndicator.adaptive` that re-dispatches
/// `RecipeMatching` on pull-to-refresh. Nested `BlocBuilder`s observe
/// `ProfileBloc` (filtered on `userProfile` changes) and `RecipeBloc` to drive
/// the loading, empty, and populated state branches that render `ShimmerList`,
/// a localized empty message, or a list of `RecipeCard` widgets.
class RecipeMain extends StatefulWidget {
  /// Creates the main recipe screen widget.
  const RecipeMain({super.key});

  /// Creates the mutable state object that drives this widget.
  @override
  State<RecipeMain> createState() => _RecipeMainState();
}

class _RecipeMainState extends State<RecipeMain> {
  /// Dispatches `RecipeMatching()` the first time the screen mounts when
  /// `RecipeBloc.state.items` is null; this establishes the matches view as
  /// the default UX entry point for the recipe feature.
  @override
  void initState() {
    RecipeBloc bloc = context.read<RecipeBloc>();
    if (bloc.state.items == null) {
      context.read<RecipeBloc>().add(RecipeMatching());
    }
    super.initState();
  }

  /// Composes the `PlatformScaffold`, nested `BlocBuilder<ProfileBloc>`
  /// (filtered on `userProfile`), `BlocBuilder<RecipeBloc>`, loading / empty /
  /// list state branches, and the adaptive `RefreshIndicator` that
  /// re-dispatches `RecipeMatching` on pull-to-refresh.
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
