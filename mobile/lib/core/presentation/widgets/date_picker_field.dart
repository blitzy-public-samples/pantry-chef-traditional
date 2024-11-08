import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class DatePickerField extends StatelessWidget {
  final String? label;
  final void Function(String date)? onChange;
  final String? initialDate;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final DateFormat? dateFormat;
  final String? errorText;
  final bool isDisabled;
  final bool readOnly;
  final Color? backgroundColor;
  final Color? fieldColor;
  final bool withClearButton;
  final void Function()? onClear;

  const DatePickerField({
    super.key,
    this.label,
    this.dateFormat,
    this.onChange,
    this.initialDate,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.errorText,
    this.isDisabled = false,
    this.readOnly = false,
    this.backgroundColor,
    this.fieldColor,
    this.onClear,
    this.withClearButton = false,
  });

  _showDatePicker(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    DateTime initialDateDefault = DateTime.now();
    if (initialDate != null && (lastDate != null || DateTime.parse(initialDate!).toLocal().isAfter(DateTime.now()))) {
      initialDateDefault = DateTime.parse(initialDate!).toLocal();
    }
    if (initialDate == null && lastDate != null && lastDate!.isBefore(initialDateDefault)) {
      initialDateDefault = lastDate!;
    }
    if (firstDate != null && firstDate!.isAfter(DateTime.now()) && initialDate == null) {
      initialDateDefault = firstDate!;
    }
    final DateTime? date = await showPlatformDatePicker(
      context: context,
      initialDate: initialDateDefault,
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 120)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      cupertino: (_, __) => CupertinoDatePickerData(
        doneLabel: AppLocalizations.of(context)!.ready,
        cancelLabel: AppLocalizations.of(context)!.cancel,
        dateOrder: DatePickerDateOrder.dmy,
      ),
    );
    if (date != null) {
      onChange!(date.toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: readOnly,
      child: Material(
        color: backgroundColor ?? context.theme.appColors.beige,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                isRequired ? "${label!}*" : label!,
                style: context.theme.appTextTheme.semiBold14,
              ),
              const SizedBox(height: 8),
            ],
            Opacity(
              opacity: isDisabled ? .5 : 1,
              child: InkWell(
                onTap: isDisabled
                    ? null
                    : () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _showDatePicker(context);
                      },
                borderRadius: const BorderRadius.all(
                  Radius.circular(16),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: withClearButton && initialDate != null ? 14 : 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ),
                    border: Border.all(
                      color: context.theme.appColors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                  right: 8,
                                ),
                                child: Icon(
                                  Icons.calendar_month,
                                  color: context.theme.appColors.grey,
                                )),
                            Flexible(
                              child: FittedBox(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 1),
                                  child: Text(
                                    initialDate != null
                                        ? (dateFormat ?? DateFormat('dd.MM.yyyy'))
                                            .format(DateTime.parse(initialDate!).toLocal())
                                        : (hintText ?? ''),
                                    style: context.theme.appTextTheme.regular16.copyWith(
                                      color: initialDate != null
                                          ? context.theme.appColors.black
                                          : context.theme.appColors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      withClearButton && initialDate != null
                          ? IconButton(
                              onPressed: onClear,
                              icon: const Icon(
                                Icons.clear,
                                size: 16,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: AppLocalizations.of(context)!.clear,
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: WidgetStateProperty.all(const EdgeInsets.all(6)),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorText!,
                  style: context.theme.appTextTheme.semiBold12.copyWith(
                    color: context.theme.appColors.red,
                  ),
                  maxLines: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
