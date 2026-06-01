import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/text_field_input.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/ingredient_add/ingredient_add_bloc.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/ingredient_search_result_item.dart';

/// Modal bottom-sheet ingredient search UI presented from [IngredientSearchField]
/// via `showModalBottomSheet`. Dispatches [IngredientSearch] events on its owning
/// [IngredientAddBloc] (passed in via [bloc]): first as
/// `IngredientSearch(query: '', page: 1)` from `initState`, then on every
/// text-field change and again when the user scrolls within
/// `CommonConstants.fetchScrollOffset` (150 px) of the bottom while
/// `isNextPageAvailable && !isFetching`. Returns one of two results via
/// `Navigator.of(context).pop(...)`: an [Ingredient] when the user taps a
/// result row, or the raw query [String] when the user taps "Use this name"
/// in the empty-state. Caller (`IngredientSearchField.onChaged`) discriminates.
class SearchDialog extends StatefulWidget {
  /// The upstream [IngredientAddBloc] whose `searchResult` state this dialog
  /// reads via `BlocBuilder(buildWhen: prev.searchResult != curr.searchResult)`
  /// and whose [IngredientSearch] events this dialog dispatches.
  final IngredientAddBloc bloc;

  /// Creates a [SearchDialog] bound to the supplied [bloc]; [bloc] is required
  /// because the dialog drives its search-event stream and reads its state.
  const SearchDialog({
    super.key,
    required this.bloc,
  });

  /// Standard Flutter override returning the private state object.
  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    widget.bloc.add(IngredientSearch(query: '', page: 1));
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
                        widget.bloc.add(IngredientSearch(query: value, page: 1));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<IngredientAddBloc, IngredientAddState>(
                    buildWhen: (prev, curr) => prev.searchResult != curr.searchResult,
                    bloc: widget.bloc,
                    builder: (context, state) {
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
