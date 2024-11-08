import 'package:flutter/material.dart';
import 'package:pantry_chef/core/domain/models/select_field_item.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class SelectDialogButton<T> extends StatelessWidget {
  final SelectFieldItem<T> item;
  final bool isSelected;
  final bool showSelectButton;
  final Function()? onPress;

  const SelectDialogButton({
    super.key,
    required this.item,
    required this.isSelected,
    this.showSelectButton = true,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSelected
                ? null
                : () {
                    onPress != null ? onPress!() : Navigator.of(context).pop(item.value);
                  },
            borderRadius: const BorderRadius.all(
              Radius.circular(24),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(24),
                ),
                color: isSelected ? context.theme.appColors.lightGreen : context.theme.appColors.beige,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 16,
                ),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth - 30),
                          child: Text(
                            item.label,
                            style: context.theme.appTextTheme.semiBold14,
                          ),
                        ),
                        if (showSelectButton)
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                              border: Border.all(
                                color: isSelected ? context.theme.appColors.green : context.theme.appColors.grey,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: context.theme.appColors.green,
                                  )
                                : const SizedBox(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
