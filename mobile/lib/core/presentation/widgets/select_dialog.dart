import 'package:flutter/material.dart';
import 'package:pantry_chef/core/domain/models/select_field_item.dart';
import 'package:pantry_chef/core/presentation/widgets/select_dialog_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class SelectDialog<T> extends StatelessWidget {
  final SelectFieldItem<T> selectedItem;
  final List<SelectFieldItem<T>> items;
  final bool showSelectButton;
  final String? label;

  const SelectDialog({
    super.key,
    required this.selectedItem,
    required this.items,
    this.label,
    this.showSelectButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.appColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: context.theme.appColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 15),
            if (label != null) ...[
              Text(
                label!,
                style: context.theme.appTextTheme.semiBold14,
              ),
            ],
            const SizedBox(height: 15),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...items.map(
                      (el) {
                        return SelectDialogButton(
                          item: el,
                          isSelected: el == selectedItem,
                          showSelectButton: showSelectButton,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
