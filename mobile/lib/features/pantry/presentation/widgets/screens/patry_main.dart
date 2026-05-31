// NOTE: File name 'patry_main.dart' is preserved verbatim (typo 'patry'
// retained for compile-time stability).
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

/// Top-level overview screen for the pantry feature.
///
/// Uses a [BlocBuilder] with `buildWhen` keyed on `state.items` to skip rebuilds
/// on unrelated state changes (Source: L19 of the original file). Renders one
/// of three views depending on `state.items`:
///
/// * `null` → dispatches [PantryItemsFetched] lazily and renders a
///   [ShimmerList] placeholder
///   (Source: `mobile/lib/core/presentation/widgets/shimmer_list.dart`).
/// * empty list → renders an empty-state column with `Icons.shelves` and the
///   localized `emptyPantry` label.
/// * populated list → wraps a [GroupedListView] (grouped by `location`) in a
///   [RefreshIndicator.adaptive]; pull-to-refresh dispatches
///   [PantryItemsFetched]; each item renders via [PantryItemCard].
///
/// The widget is stateless: state is owned by the ancestor [PantryBloc] and
/// hydrated automatically via `hydrated_bloc` on app launch
/// (Source: `mobile/lib/main.dart:L14-L16`).
class PantryMain extends StatelessWidget {
  /// Const constructor; takes only the standard [Key] forwarded as `super.key`.
  const PantryMain({super.key});

  /// Builds the [BlocBuilder]-driven layout.
  ///
  /// Three rendering branches:
  /// * `state.items == null` → dispatch [PantryItemsFetched] lazily and
  ///   return [ShimmerList] as a skeleton placeholder.
  /// * `state.items!.isEmpty` → return a vertically centered `Icons.shelves`
  ///   icon plus the localized `emptyPantry` label.
  /// * populated `state.items` → wrap a [GroupedListView] in a
  ///   [RefreshIndicator.adaptive] keyed for pull-to-refresh.
  ///
  /// The [GroupedListView] groups items by `element.location`, sorts items
  /// ascending by `id`, and delegates per-item rendering to [PantryItemCard].
  /// The optimization `buildWhen: (prev, curr) => prev.items != curr.items`
  /// prevents rebuilds on unrelated state field changes.
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
