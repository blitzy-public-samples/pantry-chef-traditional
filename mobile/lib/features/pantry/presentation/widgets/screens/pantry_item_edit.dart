import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/ingredient_location.dart';
import 'package:pantry_chef/core/domain/models/select_field_item.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/presentation/widgets/confirmation_dialog.dart';
import 'package:pantry_chef/core/presentation/widgets/date_picker_field.dart';
import 'package:pantry_chef/core/presentation/widgets/select_field.dart';
import 'package:pantry_chef/core/presentation/widgets/text_field_input.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/presentation/bloc/pantry_edit_item/pantry_item_edit_bloc.dart';
import 'package:collection/collection.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pantry_chef/features/pantry/presentation/bloc/pantry/pantry_bloc.dart';

class PantryItemEdit extends StatelessWidget {
  final PantryItem item;

  const PantryItemEdit({super.key, required this.item});

  void _showDeleteDialog(BuildContext context) async {
    bool? result = await showPlatformDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        content: AppLocalizations.of(context)!.deletepantryItemText,
      ),
    );
    if (result == true) {
      context.read<PantryItemEditBloc>().add(DeleteConfirmed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantryItemEditBloc(
        id: item.id,
        quantity: item.quantity,
        location: item.location,
        expirationDate: item.expirationDate,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<PantryItemEditBloc, PantryItemEditState>(
            listenWhen: (prev, curr) => prev.isFetching != curr.isFetching,
            listener: (context, state) {
              if (state.isFetching) {
                context.loaderOverlay.show();
              } else {
                context.loaderOverlay.hide();
              }
            },
          ),
          BlocListener<PantryItemEditBloc, PantryItemEditState>(
            listenWhen: (prev, curr) => prev.updatedItem != curr.updatedItem && curr.updatedItem != null,
            listener: (context, state) {
              context.read<PantryBloc>().add(PantryItemUpdated(item: state.updatedItem!));
              Navigator.of(context).pop();
            },
          ),
          BlocListener<PantryItemEditBloc, PantryItemEditState>(
            listenWhen: (prev, curr) => prev.deleted != curr.deleted && curr.deleted,
            listener: (context, state) {
              context.read<PantryBloc>().add(PantryItemDeleted(id: state.id));
              Navigator.of(context).pop();
            },
          ),
        ],
        child: Builder(builder: (context) {
          return PlatformScaffold(
            appBar: getAppBarWidget(context,
                title: AppLocalizations.of(context)!.editItem,
                trailingAction: IconButton(
                  onPressed: () {
                    _showDeleteDialog(context);
                  },
                  icon: Icon(Icons.delete),
                  iconSize: 30,
                  color: context.theme.appColors.red,
                )),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: CommonConstants.pagePadding, vertical: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: constraints.maxWidth / 2 - 6,
                                  child: BlocBuilder<PantryItemEditBloc, PantryItemEditState>(
                                    buildWhen: (prev, curr) =>
                                        prev.quantity != curr.quantity || prev.quantityError != curr.quantityError,
                                    builder: (context, state) {
                                      return TextFieldInput(
                                        label: AppLocalizations.of(context)!.quantity,
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        initialText: state.quantity,
                                        maxLength: 6,
                                        errorText:
                                            state.quantityError ? AppLocalizations.of(context)!.requiredField : null,
                                        onChanged: (value) => context.read<PantryItemEditBloc>().add(
                                              DataChanged(quantity: value),
                                            ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth / 2 - 6,
                                  child: BlocBuilder<PantryItemEditBloc, PantryItemEditState>(
                                    buildWhen: (prev, curr) => false,
                                    builder: (context, state) {
                                      return TextFieldInput(
                                        label: AppLocalizations.of(context)!.unit,
                                        initialText: item.ingridient.unit.name,
                                        disabled: true,
                                        onChanged: (_) {},
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<PantryItemEditBloc, PantryItemEditState>(
                              buildWhen: (prev, curr) => prev.expirationDate != curr.expirationDate,
                              builder: (_, state) {
                                return DatePickerField(
                                  label: AppLocalizations.of(context)!.expDate,
                                  initialDate: state.expirationDate,
                                  firstDate: DateTime.parse(state.expirationDate),
                                  onChange: (date) =>
                                      context.read<PantryItemEditBloc>().add(DataChanged(expirationDate: date)),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<PantryItemEditBloc, PantryItemEditState>(
                              buildWhen: (prev, curr) => prev.location != curr.location,
                              builder: (context, state) {
                                List<SelectFieldItem> locations =
                                    ingredientLocation.map((el) => SelectFieldItem(label: el, value: el)).toList();
                                return SelectField(
                                  label: AppLocalizations.of(context)!.location,
                                  selectedValue:
                                      locations.firstWhereOrNull((el) => el.value == state.location) ?? locations[0],
                                  items: locations,
                                  onChange: (value) =>
                                      context.read<PantryItemEditBloc>().add(DataChanged(location: value)),
                                );
                              },
                            ),
                          ],
                        ),
                        ActionButton(
                          text: AppLocalizations.of(context)!.save,
                          onPress: () {
                            context.read<PantryItemEditBloc>().add(ChangedDataSaved());
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
