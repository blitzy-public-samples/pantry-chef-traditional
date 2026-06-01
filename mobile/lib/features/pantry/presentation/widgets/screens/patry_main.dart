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

/// Pantry overview screen that lists pantry items grouped by their
/// `location`.
///
/// Reads from [PantryBloc] via a [BlocBuilder] that rebuilds only when
/// `items` changes. The nullable `items` drives three states:
/// * null dispatches [PantryItemsFetched] and shows a [ShimmerList];
/// * empty shows an `Icons.shelves` icon with the localized
///   `emptyPantry` message;
/// * populated renders a [RefreshIndicator.adaptive] wrapping a
///   [GroupedListView] of [PantryItemCard]s, grouped by location and
///   sorted by `id` ascending.
class PantryMain extends StatelessWidget {
  const PantryMain({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: BlocBuilder<PantryBloc, PantryState>(
        // BlocBuilder rebuilds only when `items` changes.
        buildWhen: (prev, curr) => prev.items != curr.items,
        builder: (context, state) {
          // Items not yet loaded: trigger a fetch and show a shimmer.
          if (state.items == null) {
            context.read<PantryBloc>().add(PantryItemsFetched());
            return const ShimmerList();
          }
          // Loaded but empty: show the empty-pantry placeholder.
          if (state.items!.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Shelves icon plus the localized empty-pantry text.
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
          // Populated: pull-to-refresh re-dispatches PantryItemsFetched.
          return RefreshIndicator.adaptive(
            color: context.theme.appColors.green,
            onRefresh: () async => context.read<PantryBloc>().add(PantryItemsFetched()),
            // Grouped list keyed by location, sorted by id ascending.
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
              // Each row renders a PantryItemCard for the element.
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
