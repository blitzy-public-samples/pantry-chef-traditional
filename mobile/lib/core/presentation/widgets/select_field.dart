import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/domain/models/select_field_item.dart';
import 'package:pantry_chef/core/presentation/widgets/select_dialog.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class SelectField<T> extends StatelessWidget {
  final String label;
  final SelectFieldItem<T> selectedValue;
  final List<SelectFieldItem<T>> items;
  final Function(T? value) onChange;
  final Color? fieldColor;
  final String? labelSubtitle;
  final bool isRequired;
  final bool isDisabled;
  final bool isError;

  const SelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChange,
    this.fieldColor,
    this.labelSubtitle,
    this.isRequired = false,
    this.isDisabled = false,
    this.isError = false,
  });

  _openSelectDialog(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    T? result = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: context.theme.appColors.grey.withOpacity(0.7),
      builder: (_) {
        return SelectDialog<T>(
          items: items,
          selectedItem: selectedValue,
        );
      },
    );
    if (result != null) {
      onChange(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: isRequired ? "$label*" : label,
                style: context.theme.appTextTheme.semiBold14,
              ),
            ],
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: isDisabled ? .5 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      _openSelectDialog(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Ink(
                  decoration: BoxDecoration(
                    border: isError ? Border.all(color: context.theme.appColors.red) : null,
                    color: fieldColor ?? context.theme.appColors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: constraints.maxWidth - 24),
                                  child: Text(
                                    selectedValue.label,
                                    style: context.theme.appTextTheme.regular16,
                                  ),
                                ),
                                if (labelSubtitle != null && labelSubtitle!.isNotEmpty) ...[
                                  Text(
                                    labelSubtitle!,
                                    style: context.theme.appTextTheme.regular14,
                                  ),
                                ],
                              ],
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: context.theme.appColors.black,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              AppLocalizations.of(context)!.requiredField,
              style: context.theme.appTextTheme.semiBold12.copyWith(
                color: context.theme.appColors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
