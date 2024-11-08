import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantry_chef/core/constants/icons.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class TextFieldInput extends StatefulWidget {
  final String label;
  final void Function(String value) onChanged;
  final String? initialText;
  final bool disabled;
  final bool required;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? errorText;
  final int? maxLength;

  const TextFieldInput({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialText,
    this.disabled = false,
    this.required = false,
    this.inputFormatters,
    this.keyboardType,
    this.hintText,
    this.errorText,
    this.maxLength,
  });

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  late final TextEditingController textController;
  late final StreamController<bool> streamController;

  @override
  void initState() {
    streamController = StreamController<bool>();
    textController = TextEditingController(text: widget.initialText ?? '');
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // textController.text = widget.initialText ?? '';
    return Opacity(
      opacity: widget.disabled ? .5 : 1,
      child: Material(
        color: context.theme.appColors.beige,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.required ? "${widget.label}*" : widget.label,
              style: context.theme.appTextTheme.semiBold14,
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: !widget.disabled,
              inputFormatters: widget.inputFormatters,
              cursorColor: context.theme.appColors.green,
              controller: textController,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              maxLength: widget.maxLength,
              decoration: InputDecoration(
                counterText: '',
                suffixIcon: StreamBuilder(
                  stream: streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return Tooltip(
                        message: AppLocalizations.of(context)!.delete,
                        child: InkWell(
                          onTap: () {
                            textController.text = '';
                            streamController.add(false);
                            widget.onChanged('');
                          },
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                          child: SizedBox(
                            child: Image.asset(IconsAsset.cross),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.appColors.grey,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.appColors.green,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.appColors.red,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.appColors.red,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                hintText: widget.hintText,
                hintStyle: context.theme.appTextTheme.regular16.copyWith(
                  color: context.theme.appColors.grey,
                ),
                errorMaxLines: 2,
                errorText: widget.errorText,
                errorStyle: context.theme.appTextTheme.semiBold12.copyWith(
                  color: context.theme.appColors.red,
                ),
              ),
              style: context.theme.appTextTheme.regular16.copyWith(
                color: context.theme.appColors.black,
              ),
              onChanged: (String value) {
                streamController.add(value != '');
                widget.onChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
