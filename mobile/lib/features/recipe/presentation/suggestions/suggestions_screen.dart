import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_list.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/recipe/data/dto/recipe_filters.dto.dart';
import 'package:pantry_chef/features/recipe/presentation/suggestions/bloc/suggestions_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/suggestions/widgets/suggestion_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// "What Can I Make Tonight?" suggestions screen.
///
/// Renders the pantry-ranked recipe suggestions produced by [SuggestionsBloc]
/// in descending match-score order (READY recipes first — the list is rendered
/// exactly as returned by the backend and is never re-sorted client-side).
///
/// The screen handles four presentation states, evaluated in strict precedence
/// order inside the [BlocBuilder]:
///   1. Loading — a shimmer skeleton while a fetch is in flight or before the
///      first fetch has completed ([SuggestionsState.items] is `null`).
///   2. Error — the localized error copy plus a retry affordance that
///      re-dispatches the fetch while preserving the active filters.
///   3. Empty — the empty-pantry illustration and guidance copy when the fetch
///      succeeded but returned no suggestions.
///   4. Loaded — the ALMOST THERE / QUICK MAKE filter toggles above a
///      pull-to-refresh list of [SuggestionCard]s.
///
/// The initial fetch is dispatched from [initState] only when the bloc has not
/// yet loaded any items, mirroring the existing recipe list screen so that
/// re-entering the screen reuses the already-loaded state instead of refetching.
class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  @override
  void initState() {
    final SuggestionsBloc bloc = context.read<SuggestionsBloc>();
    // Only trigger the initial load when nothing has been fetched yet
    // (items == null). A populated or empty (non-null) list means the bloc has
    // already resolved a fetch, so we keep that state to avoid a redundant call.
    if (bloc.state.items == null) {
      bloc.add(const SuggestionsFetched());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: getAppBarWidget(
        context,
        title: AppLocalizations.of(context)!.whatCanIMakeTonight,
      ),
      body: BlocBuilder<SuggestionsBloc, SuggestionsState>(
        builder: (context, state) {
          // 1. Loading — a fetch is in flight, or no fetch has completed yet
          // (items == null). The `error == null` guard lets a fetch that FAILED
          // on first load fall through to the error branch below instead of
          // showing the skeleton indefinitely: on failure the bloc leaves items
          // null and isFetching false while setting error. An in-flight fetch
          // always clears error first, so loading still takes precedence then.
          if ((state.isFetching || state.items == null) &&
              state.error == null) {
            return const ShimmerList(cardHeight: 200);
          }

          // 2. Error — localized message plus a retry button. The retry carries
          // the active filters so the user's toggle selection is preserved.
          if (state.error != null) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.suggestionsErrorMessage,
                    textAlign: TextAlign.center,
                    style: context.theme.appTextTheme.semiBold14.copyWith(
                      color: context.theme.appColors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CommonConstants.pagePadding,
                    ),
                    child: ActionButton(
                      text: AppLocalizations.of(context)!.retry,
                      onPress: () => context.read<SuggestionsBloc>().add(
                            SuggestionsFetched(filters: state.filters),
                          ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. Empty — the fetch succeeded but produced no suggestions (e.g. an
          // empty pantry): show the illustration and the guidance copy.
          if (state.items!.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_pantry.webp',
                    width: 200,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CommonConstants.pagePadding,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.suggestionsEmptyMessage,
                      textAlign: TextAlign.center,
                      style: context.theme.appTextTheme.semiBold14.copyWith(
                        color: context.theme.appColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Loaded — filter toggles above a pull-to-refresh list of ranked
          // suggestions. Items are rendered in the backend's order (match score
          // descending, READY first) and are never re-sorted here.
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CommonConstants.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  // Wrap (not Row) so the two chips reflow onto a second line
                  // instead of overflowing on narrow widths or at larger text
                  // scales; `spacing`/`runSpacing` provide the inter-chip gaps.
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(
                          AppLocalizations.of(context)!.almostThere,
                        ),
                        selected: state.filters.isAlmostThere,
                        selectedColor: context.theme.appColors.green,
                        // RecipeFiltersDto has no copyWith, so build a fresh
                        // instance carrying the toggled flag plus the other
                        // flag's current value.
                        onSelected: (value) =>
                            context.read<SuggestionsBloc>().add(
                                  SuggestionsFetched(
                                    filters: RecipeFiltersDto(
                                      isAlmostThere: value,
                                      isQuickMake: state.filters.isQuickMake,
                                    ),
                                  ),
                                ),
                      ),
                      FilterChip(
                        label: Text(
                          AppLocalizations.of(context)!.quickMake,
                        ),
                        selected: state.filters.isQuickMake,
                        selectedColor: context.theme.appColors.green,
                        onSelected: (value) => context
                            .read<SuggestionsBloc>()
                            .add(
                              SuggestionsFetched(
                                filters: RecipeFiltersDto(
                                  isAlmostThere: state.filters.isAlmostThere,
                                  isQuickMake: value,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator.adaptive(
                    color: context.theme.appColors.green,
                    onRefresh: () async => context.read<SuggestionsBloc>().add(
                          SuggestionsFetched(filters: state.filters),
                        ),
                    child: ListView.builder(
                      itemCount: state.items!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: SuggestionCard(item: state.items![index]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
