import 'package:flutter/material.dart';
import 'package:pantry_chef/core/presentation/widgets/image_widget.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SuggestionCard extends StatelessWidget {
  final RecipeSuggestionDto item;

  const SuggestionCard({
    super.key,
    required this.item,
  });

  Color _getProgressBarColor(BuildContext context) {
    if (item.matchScore >= 0.7) {
      return context.theme.appColors.lightGreen;
    }
    if (item.matchScore >= 0.3 && item.matchScore < 0.7) {
      return context.theme.appColors.lightOrange;
    }
    return context.theme.appColors.brightRed;
  }

  Color _getStatusColor(BuildContext context) {
    switch (item.status) {
      case 'READY':
        return context.theme.appColors.lightGreen;
      case 'ALMOST_THERE':
        return context.theme.appColors.lightOrange;
      case 'MISSING':
        return context.theme.appColors.brightRed;
      default:
        return context.theme.appColors.grey;
    }
  }

  String _getStatusLabel(BuildContext context) {
    switch (item.status) {
      case 'READY':
        return AppLocalizations.of(context)!.ready;
      case 'ALMOST_THERE':
        return AppLocalizations.of(context)!.almostThere;
      case 'MISSING':
        return AppLocalizations.of(context)!.missing;
      default:
        return item.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          ImageWidget(
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            imageUrl: item.recipe.imageUrl,
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
                  item.recipe.title,
                  style: context.theme.appTextTheme.semiBold18,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  minHeight: 10,
                  color: _getProgressBarColor(context),
                  backgroundColor: context.theme.appColors.grey,
                  value: item.matchScore,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        _getStatusLabel(context),
                        style: context.theme.appTextTheme.semiBold12,
                      ),
                      backgroundColor: _getStatusColor(context),
                      side: BorderSide(color: context.theme.appColors.grey),
                    ),
                    if (item.isQuickMake)
                      Chip(
                        label: Text(
                          AppLocalizations.of(context)!.quickMake,
                          style: context.theme.appTextTheme.semiBold12,
                        ),
                        backgroundColor: context.theme.appColors.darkBeige,
                        side: BorderSide(color: context.theme.appColors.grey),
                      ),
                  ],
                ),
                if (item.missingIngredients.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.missingIngredients
                        .map(
                          (m) => Chip(
                            label: Text(
                              m.name,
                              style: context.theme.appTextTheme.regular14,
                            ),
                            backgroundColor: context.theme.appColors.darkBeige,
                            side: BorderSide(
                              color: context.theme.appColors.grey,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
