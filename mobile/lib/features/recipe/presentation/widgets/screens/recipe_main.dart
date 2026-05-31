import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/widgets/recipe_card.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Recipe browse/list screen.
///
/// Bootstraps recipe loading on first open and renders the loading
/// (shimmer), empty, and populated list states. The populated list
/// supports pull-to-refresh and shows one [RecipeCard] per recipe.
class RecipeMain extends StatefulWidget {
  const RecipeMain({super.key});

  @override
  State<RecipeMain> createState() => _RecipeMainState();
}

// State for RecipeMain; triggers the initial fetch.
class _RecipeMainState extends State<RecipeMain> {
  @override
  void initState() {
    // Read the RecipeBloc from the widget tree.
    RecipeBloc bloc = context.read<RecipeBloc>();
    // Fetch the list ONCE: dispatch RecipeMatching only when
    // items have not been loaded yet (state.items == null).
    if (bloc.state.items == null) {
      context.read<RecipeBloc>().add(RecipeMatching());
    }
    // Call super.initState() last, per Flutter convention.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Platform-adaptive scaffold is the screen root.
    return PlatformScaffold(
      // Rebuild on profile changes only when userProfile differs
      // (buildWhen guards needless rebuilds).
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (prev, curr) => prev.userProfile != curr.userProfile,
        builder: (context, profileState) {
          // Inner builder reacts to recipe-state changes.
          return BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, state) {
              // Loading state: show shimmer while fetching or before
              // the first load (state.items == null) -> ShimmerList(200).
              if (state.isFetching || state.items == null) {
                return ShimmerList(cardHeight: 200);
              }
              // Empty state: centered list icon + localized
              // recipeEmptyMessage when the list is empty.
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
              // Favorite ids come from the profile; default to empty.
              final favoriteList = profileState.userProfile?.favoriteRecipes ?? [];
              // Pull-to-refresh re-dispatches RecipeMatching() to reload.
              return RefreshIndicator.adaptive(
                color: context.theme.appColors.green,
                onRefresh: () async => context.read<RecipeBloc>().add(RecipeMatching()),
                // Populated state: one RecipeCard per item; isFavorite is
                // true when favoriteList contains the recipe id.
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
