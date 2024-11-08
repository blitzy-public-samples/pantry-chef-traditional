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

class RecipeCard extends StatelessWidget {
  final Recipe item;
  final bool isFavorite;

  const RecipeCard({
    super.key,
    required this.item,
    this.isFavorite = false,
  });

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
      child: InkWell(
        onTap: () {
          context.read<RecipeBloc>().add(RecipeDetailedSelected(id: item.id));
          Navigator.of(context).pushNamed(Navigation.recipeDetailed);
        },
        child: Column(
          children: [
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
                  Text(
                    item.description,
                    style: context.theme.appTextTheme.regular14,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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
