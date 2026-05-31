import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/app_icon_button.dart';
import 'package:pantry_chef/core/presentation/widgets/image_widget.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A tappable summary card that renders a single [item] recipe.
///
/// Shows the recipe image, title, description, and the
/// preparation/cooking/servings figures, plus an optional
/// match-score bar and a favorite toggle. Intended for recipe
/// lists, feeds, and recommendation grids.
///
/// Stateless: it holds no local state and delegates state changes
/// to BLoCs. [RecipeBloc] records the selected recipe and drives
/// navigation; [ProfileBloc] owns the favorites list toggled here.
class RecipeCard extends StatelessWidget {
  /// The recipe rendered by this card.
  final Recipe item;
  /// Whether the recipe is currently in the user's favorites.
  final bool isFavorite;

  /// Creates a card for [item]; [isFavorite] seeds the toggle.
  const RecipeCard({
    super.key,
    required this.item,
    this.isFavorite = false,
  });

  // Returns the match-score bar color from the theme: a score of
  // >= 0.7 maps to lightGreen, >= 0.3 and < 0.7 to lightOrange,
  // and anything lower maps to brightRed.
  // Force-unwraps item.matchScore!, so it is only safe to call when
  // matchScore != null; the build method guards this at the call
  // site with its matchScore != null check.
  Color _getProgressBarColor(BuildContext context) {
    if (item.matchScore! >= 0.7) {
      return context.theme.appColors.lightGreen;
    }
    if (item.matchScore! >= 0.3 && item.matchScore! < 0.7) {
      return context.theme.appColors.lightOrange;
    }
    return context.theme.appColors.brightRed;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      // Wrap the whole card in an InkWell so the entire surface is
      // tappable.
      child: InkWell(
        onTap: () {
          // Record selection in RecipeBloc BEFORE navigating so the
          // detail screen can resolve the active recipe: dispatch
          // RecipeDetailedSelected first, then push the detail route.
          context.read<RecipeBloc>().add(RecipeDetailedSelected(id: item.id));
          Navigator.of(context).pushNamed(Navigation.recipeDetailed);
        },
        child: Column(
          children: [
            // Cover image for the recipe; fixed 150px tall, full width.
            ImageWidget(
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              imageUrl: item.imageUrl,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 12,
                top: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.theme.appTextTheme.semiBold18,
                  ),
                  const SizedBox(height: 4),
                  // Description is clamped to 3 lines with an
                  // ellipsis when it overflows.
                  Text(
                    item.description,
                    style: context.theme.appTextTheme.regular14,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Row of preparation, cooking, and servings figures.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.preparation,
                            style: context.theme.appTextTheme.semiBold14,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.prepTime} ${AppLocalizations.of(context)!.minuteAbbr}',
                            style: context.theme.appTextTheme.regular14,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.cooking,
                            style: context.theme.appTextTheme.semiBold14,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.cookTime} ${AppLocalizations.of(context)!.minuteAbbr}',
                            style: context.theme.appTextTheme.regular14,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.servings,
                            style: context.theme.appTextTheme.semiBold14,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.servings} ${AppLocalizations.of(context)!.minuteAbbr}',
                            style: context.theme.appTextTheme.regular14,
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Match-score bar renders only when matchScore
                      // != null; bar color comes from
                      // _getProgressBarColor and its value is
                      // item.matchScore.
                      SizedBox(
                        width: 200,
                        child: item.matchScore != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.matchScore,
                                    style: context.theme.appTextTheme.semiBold12,
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    minHeight: 10,
                                    color: _getProgressBarColor(context),
                                    backgroundColor: context.theme.appColors.grey,
                                    value: item.matchScore,
                                  ),
                                ],
                              )
                            : null,
                      ),
                      // Favorite toggle: icon reflects isFavorite;
                      // onPress dispatches FavoriteRecipesListUpdated.
                      // Cross-feature: this recipe widget toggles a
                      // favorite via ProfileBloc; the profile feature
                      // owns that bloc and event.
                      AppIconButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: context.theme.appColors.red,
                        backgroundColor: Colors.transparent,
                        onPress: () {
                          context.read<ProfileBloc>().add(
                                FavoriteRecipesListUpdated(
                                  recipeId: item.id,
                                  isFavorite: !isFavorite,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
