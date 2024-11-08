import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecipeDetailed extends StatelessWidget {
  const RecipeDetailed({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (_, state) {
        Recipe item = state.items!.firstWhere((el) => el.id == state.detailedItemId);
        return PlatformScaffold(
          appBar: getAppBarWidget(context, title: item.title),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 24,
                horizontal: CommonConstants.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.ingredients}:',
                    style: context.theme.appTextTheme.semiBold14,
                  ),
                  const SizedBox(height: 8),
                  ...item.ingridientList
                      .map(
                        (el) => Text(
                          '${el.ingridient.name}, ${el.amount} ${el.unit}',
                          style: context.theme.appTextTheme.regular14,
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 24),
                  Text(
                    '${AppLocalizations.of(context)!.instructions}:',
                    style: context.theme.appTextTheme.semiBold14,
                  ),
                  const SizedBox(height: 8),
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
