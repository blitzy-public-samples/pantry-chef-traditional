import 'package:flutter/material.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/ingredient_add/ingredient_add_bloc.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/ingredient_search_dialog.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class IngredientSearchField extends StatelessWidget {
  final String label;
  final void Function(dynamic value) onChaged;
  final IngredientAddBloc bloc;
  final String? displayValue;
  final String? hintText;

  const IngredientSearchField({
    super.key,
    required this.label,
    required this.onChaged,
    required this.bloc,
    this.displayValue,
    this.hintText,
  });

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
