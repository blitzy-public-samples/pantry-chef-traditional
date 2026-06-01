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

/// Per-item edit screen for a single [PantryItem].
///
/// Creates a fresh [PantryItemEditBloc] (seeded with the item's `id`,
/// `quantity`, `location`, `expirationDate`) via [BlocProvider]
/// (Source: L40-L46) and wires three [BlocListener]s in a [MultiBlocListener]:
///
/// * **Loader overlay** (L49-L58) — toggles `context.loaderOverlay` based on
///   `isFetching` state changes.
/// * **Update success** (L59-L65) — when `state.updatedItem` becomes non-null,
///   dispatches `PantryItemUpdated(item: state.updatedItem!)` to the parent
///   [PantryBloc] and pops the route.
/// * **Delete success** (L66-L72) — when `state.deleted` becomes `true`,
///   dispatches `PantryItemDeleted(id: state.id)` to the parent [PantryBloc]
///   and pops the route.
///
/// The body renders a form composed of `TextFieldInput` (quantity + readonly
/// unit), `DatePickerField` (expirationDate), `SelectField` (location
/// populated from the `ingredientLocation` constant in
/// `mobile/lib/core/constants/ingredient_location.dart:L1`), and an
/// `ActionButton` ("Save") that dispatches `ChangedDataSaved`. The app bar's
/// trailing delete icon opens a `ConfirmationDialog` via the private
/// [_showDeleteDialog] helper.
class PantryItemEdit extends StatelessWidget {
  /// The [PantryItem] being edited.
  ///
  /// Values are used to seed the bloc's initial state via the
  /// [BlocProvider.create] factory at L40-L46:
  /// * `item.id` — primary key; also captured by the bloc so the deleted
  ///   listener can dispatch `PantryItemDeleted(id: state.id)`.
  /// * `item.quantity` — initial numeric quantity.
  /// * `item.location` — initial location enum string (one of
  ///   `'fridge'`, `'freezer'`, `'pantry'`).
  /// * `item.expirationDate` — ISO-8601 string used by the date picker as
  ///   both `initialDate` and `firstDate`.
  ///
  /// The readonly unit field reads `item.ingridient.unit.name` (spelling
  /// preserved verbatim) and is not editable through this screen.
  final PantryItem item;

  /// Const constructor.
  ///
  /// Requires the [PantryItem] to edit, which is passed as route `arguments`
  /// when the user taps the edit affordance on a [PantryItemCard].
  const PantryItemEdit({super.key, required this.item});

  /// Displays the platform-adaptive confirmation dialog for delete.
  ///
  /// Uses `showPlatformDialog<bool>` from `flutter_platform_widgets` to render
  /// a [ConfirmationDialog] (Source:
  /// `mobile/lib/core/presentation/widgets/confirmation_dialog.dart`). On
  /// confirm (`result == true`), dispatches `DeleteConfirmed()` to the
  /// ancestor [PantryItemEditBloc]. On dismiss or cancel, no event is
  /// dispatched.
  ///
  /// The dialog content is localized via
  /// `AppLocalizations.of(context)!.deletepantryItemText`.
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

  /// Builds the [BlocProvider] + [MultiBlocListener] + form layout.
  ///
  /// The [BlocProvider] is the entry point that creates the ephemeral
  /// [PantryItemEditBloc] seeded with the item's persisted values. The
  /// [MultiBlocListener] orchestrates side effects:
  ///
  /// 1. Loader overlay show/hide based on `isFetching` (L49-L58).
  /// 2. Parent [PantryBloc] notification + route pop on `updatedItem`
  ///    becoming non-null (L59-L65).
  /// 3. Parent [PantryBloc] notification + route pop on `deleted` becoming
  ///    `true` (L66-L72).
  ///
  /// The form body composes:
  /// * `TextFieldInput` for quantity, keyed via [BlocBuilder] on
  ///   `quantity`/`quantityError` (L102-L118).
  /// * Readonly unit `TextFieldInput` derived from `item.ingridient.unit.name`
  ///   (spelling preserved) at L125-L130.
  /// * `DatePickerField` for `expirationDate`, keyed on the bloc state
  ///   (L137-L148).
  /// * `SelectField` for location, populated from the `ingredientLocation`
  ///   constant (L150-L164).
  /// * `ActionButton` "Save" dispatching `ChangedDataSaved()` (L167-L172).
  ///
  /// The app bar includes a trailing red delete `IconButton` that opens the
  /// confirmation dialog via [_showDeleteDialog].
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
