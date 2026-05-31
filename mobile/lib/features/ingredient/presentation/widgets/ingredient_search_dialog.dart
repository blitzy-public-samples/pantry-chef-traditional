import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/text_field_input.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/ingredient_add/ingredient_add_bloc.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/ingredient_search_result_item.dart';

/// Modal ingredient-search UI rendered as a bottom sheet.
///
/// Shows a search field and a paginated, scrollable result list so
/// the user can pick an existing ingredient or reuse the typed name.
/// The [bloc] is the [IngredientAddBloc] that drives the search
/// query, pagination, and result state this widget renders.
class SearchDialog extends StatefulWidget {
  final IngredientAddBloc bloc;

  const SearchDialog({
    super.key,
    required this.bloc,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

/// State for [SearchDialog]: seeds the initial search, paginates
/// on scroll, and rebuilds the result list from the bloc.
class _SearchDialogState extends State<SearchDialog> {
  // Controls the result list and drives infinite-scroll pagination.
  // KNOWN ISSUE: this ScrollController is never disposed; no
  // dispose() override exists on _SearchDialogState.
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // Seed the first page of results with an empty query (page 1).
    widget.bloc.add(IngredientSearch(query: '', page: 1));
    // Request the next page when the scroll position passes within
    // CommonConstants.fetchScrollOffset of the bottom, while the
    // bloc reports isNextPageAvailable and is not already fetching.
    _scrollController.addListener(() {
      final state = widget.bloc.state;
      if (_scrollController.position.pixels >
              (_scrollController.position.maxScrollExtent - CommonConstants.fetchScrollOffset) &&
          widget.bloc.state.isNextPageAvailable &&
          !state.isFetching) {
        widget.bloc.add(
          IngredientSearch(
            query: state.query,
            page: state.page + 1,
          ),
        );
      }
    });
    super.initState();
  }

  /// Builds the bottom-sheet UI for [SearchDialog].
  ///
  /// Renders a themed, rounded beige [Container] containing a
  /// [TextFieldInput] search box and a [BlocBuilder] that switches
  /// between three states: (a) a no-results message plus a
  /// "use this name" [ActionButton] that pops the typed query;
  /// (b) a scrollable [CustomScrollView] / [SliverList] of
  /// [IngredientSearchResultItem] rows; and (c) an empty
  /// [SizedBox] placeholder shown before any query runs.
  /// [context] supplies theme and localization lookups.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        height: constraints.maxHeight - CommonConstants.homeAppBarHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.theme.appColors.beige,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: 12,
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: context.theme.appColors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CommonConstants.pagePadding),
                    child: TextFieldInput(
                      label: AppLocalizations.of(context)!.search,
                      onChanged: (value) {
                        // Re-query from page 1 on each keystroke.
                        widget.bloc.add(IngredientSearch(query: value, page: 1));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<IngredientAddBloc, IngredientAddState>(
                    // Rebuild only when the search results change.
                    buildWhen: (prev, curr) => prev.searchResult != curr.searchResult,
                    bloc: widget.bloc,
                    builder: (context, state) {
                      // (a) No matches: show a no-results message
                      // and an ActionButton that pops the query.
                      if (state.query != '' && state.searchResult != null && state.searchResult!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: CommonConstants.pagePadding),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.noDataFound,
                                style: context.theme.appTextTheme.semiBold14,
                              ),
                              const SizedBox(height: 24),
                              ActionButton(
                                text: AppLocalizations.of(context)!.useThisName,
                                onPress: () => Navigator.of(context).pop(state.query),
                              ),
                            ],
                          ),
                        );
                      }
                      // (b) Results: show the scrollable list.
                      if (state.searchResult != null && state.searchResult!.isNotEmpty) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight - 140 - MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverList.builder(
                                itemCount: state.searchResult!.length,
                                itemBuilder: (_, index) {
                                  return IngredientSearchResultItem(
                                    item: state.searchResult![index],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }
                      // (c) No query yet (or null result): nothing.
                      return const SizedBox();
                    },
                  ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}
