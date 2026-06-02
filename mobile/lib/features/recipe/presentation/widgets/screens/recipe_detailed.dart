import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Recipe detail page.
///
/// Renders the selected recipe's title, ingredient list, and
/// step-by-step instructions, resolved from RecipeBloc state.
class RecipeDetailed extends StatelessWidget {
  const RecipeDetailed({super.key});

  /// Builds the detail view from the current [RecipeBloc] state.
  @override
  Widget build(BuildContext context) {
    // Read recipe state to resolve the active recipe.
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (_, state) {
        // Resolve the recipe whose id == state.detailedItemId.
        // Assumes a valid list + matching id (force-unwraps
        // state.items!).
        Recipe item = state.items!.firstWhere((el) => el.id == state.detailedItemId);
        // Platform scaffold with a shared app bar showing the title.
        return PlatformScaffold(
          appBar: getAppBarWidget(context, title: item.title),
          // Safe, scrollable body using the shared page padding.
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 24,
                horizontal: CommonConstants.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Localized "ingredients:" section heading.
                  Text(
                    '${AppLocalizations.of(context)!.ingredients}:',
                    style: context.theme.appTextTheme.semiBold14,
                  ),
                  const SizedBox(height: 8),
                  // List each ingredient as "name, amount unit".
                  // NOTE: item.ingridientList and el.ingridient use
                  // intentional, stable (sic) identifiers from the models.
                  ...item.ingridientList
                      .map(
                        (el) => Text(
                          '${el.ingridient.name}, ${el.amount} ${el.unit}',
                          style: context.theme.appTextTheme.regular14,
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 24),
                  // Localized "instructions:" section heading.
                  Text(
                    '${AppLocalizations.of(context)!.instructions}:',
                    style: context.theme.appTextTheme.semiBold14,
                  ),
                  const SizedBox(height: 8),
                  // List each step as "step. description"; each element
                  // is an InstractionItem (sic, intentional stable name)
                  // exposing step and description fields.
                  ...item.instructions.map((el) {
                    return Text(
                      '${el.step}. ${el.description}',
                      style: context.theme.appTextTheme.regular14,
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
