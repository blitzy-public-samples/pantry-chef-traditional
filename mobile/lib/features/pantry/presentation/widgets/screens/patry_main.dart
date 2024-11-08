import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_list.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/presentation/bloc/pantry/pantry_bloc.dart';
import 'package:pantry_chef/features/pantry/presentation/widgets/pantry_item_card.dart';

class PantryMain extends StatelessWidget {
  const PantryMain({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: BlocBuilder<PantryBloc, PantryState>(
        buildWhen: (prev, curr) => prev.items != curr.items,
        builder: (context, state) {
          if (state.items == null) {
            context.read<PantryBloc>().add(PantryItemsFetched());
            return const ShimmerList();
          }
          if (state.items!.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shelves,
                    size: 100,
                    color: context.theme.appColors.grey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.emptyPantry,
                    style: context.theme.appTextTheme.regular14.copyWith(
                      color: context.theme.appColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator.adaptive(
            color: context.theme.appColors.green,
            onRefresh: () async => context.read<PantryBloc>().add(PantryItemsFetched()),
            child: GroupedListView<PantryItem, String>(
              elements: state.items!,
              groupBy: (element) => element.location,
              padding: EdgeInsets.only(bottom: 24),
              groupSeparatorBuilder: (String groupByValue) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  groupByValue,
                  style: context.theme.appTextTheme.semiBold18,
                ),
              ),
              itemBuilder: (context, PantryItem element) => PantryItemCard(item: element),
              itemComparator: (item1, item2) => item1.id.compareTo(item2.id),
              order: GroupedListOrder.ASC,
            ),
          );
        },
      ),
    );
  }
}
