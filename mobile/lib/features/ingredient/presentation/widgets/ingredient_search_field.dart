import 'package:flutter/material.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/ingredient_add/ingredient_add_bloc.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/ingredient_search_dialog.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

/// A picker-style, form-like selector that looks like a text field but
/// opens [SearchDialog] in a modal bottom sheet instead of accepting
/// direct keyboard input. It renders [displayValue] when set (otherwise
/// [hintText]) and delegates the chosen value back through [onChaged].
class IngredientSearchField extends StatelessWidget {
  /// Caption rendered above the field via appTextTheme.semiBold14.
  final String label;
  // KNOWN ISSUE: name 'onChaged' is misspelled; preserved as-is.
  /// Callback invoked with the value selected from [SearchDialog].
  final void Function(dynamic value) onChaged;
  /// [IngredientAddBloc] forwarded into [SearchDialog] to drive search.
  final IngredientAddBloc bloc;
  /// Current selected text shown in black; null shows [hintText].
  final String? displayValue;
  /// Placeholder shown in grey when [displayValue] is null.
  final String? hintText;

  const IngredientSearchField({
    super.key,
    required this.label,
    required this.onChaged,
    required this.bloc,
    this.displayValue,
    this.hintText,
  });

  /// Builds the labeled tap-target: a [Column] with the [label] and a
  /// rounded Material/InkWell/Ink surface showing [displayValue] or
  /// [hintText].
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
              // Unfocus the keyboard, then open SearchDialog in a
              // scrollable modal bottom sheet (isScrollControlled).
              FocusManager.instance.primaryFocus?.unfocus();
              dynamic result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SearchDialog(bloc: bloc),
              );
              // Invoke onChaged(result) only when a value was
              // returned (non-null).
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
