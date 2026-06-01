import 'package:flutter/material.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/ingredient_add/ingredient_add_bloc.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/ingredient_search_dialog.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

/// Tappable picker field that, on tap, opens [SearchDialog] as a modal bottom
/// sheet (`isScrollControlled: true`) and surfaces the user's selection back
/// to the caller via [onChaged]. Selection result is either an [Ingredient]
/// (when the user taps an existing match) or a [String] (the raw query when
/// the user opts "Use this name"). Renders [displayValue] (or grey [hintText]
/// when null) inside a rounded outlined `InkWell` of fixed height 52.
class IngredientSearchField extends StatelessWidget {
  /// Label displayed above the picker; rendered with `appTextTheme.semiBold14`.
  final String label;
  /// Callback invoked when the dialog returns a non-null result. Parameter is
  /// `dynamic` because the result may be either an [Ingredient] (selection) or
  /// a [String] (the raw typed query when no match was found). Callers must
  /// discriminate on type. The field name `onChaged` is preserved verbatim.
  final void Function(dynamic value) onChaged;
  /// The [IngredientAddBloc] passed through to [SearchDialog] so the dialog
  /// dispatches `IngredientSearch` events on the same bloc that owns form state.
  final IngredientAddBloc bloc;
  /// Current value shown inside the field, typically the selected ingredient's
  /// name. When null, [hintText] is displayed in grey instead.
  final String? displayValue;
  /// Placeholder text shown in grey when [displayValue] is null.
  final String? hintText;

  /// Creates a search-picker field bound to [bloc]; [label], [onChaged], and
  /// [bloc] are required, [displayValue] and [hintText] are optional.
  const IngredientSearchField({
    super.key,
    required this.label,
    required this.onChaged,
    required this.bloc,
    this.displayValue,
    this.hintText,
  });

  /// Standard Flutter `build` override.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.theme.appTextTheme.semiBold14,
        ),
        const SizedBox(height: 6),
        Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              dynamic result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SearchDialog(bloc: bloc),
              );
              if (result != null) {
                onChaged(result);
              }
            },
            child: Ink(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.theme.appColors.grey),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayValue ?? hintText ?? '',
                    style: context.theme.appTextTheme.regular16.copyWith(
                      color: displayValue != null ? context.theme.appColors.black : context.theme.appColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
