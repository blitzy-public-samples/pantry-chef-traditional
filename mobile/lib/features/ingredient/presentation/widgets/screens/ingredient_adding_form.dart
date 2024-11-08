import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/ingredient_location.dart';
import 'package:pantry_chef/core/domain/models/select_field_item.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/presentation/widgets/date_picker_field.dart';
import 'package:pantry_chef/core/utils/nullable_wrapper.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/ingredient_search_field.dart';
import 'package:pantry_chef/core/presentation/widgets/select_field.dart';
import 'package:pantry_chef/core/presentation/widgets/text_field_input.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/ingredient_add/ingredient_add_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pantry_chef/features/pantry/data/dto/create_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/presentation/bloc/pantry/pantry_bloc.dart';

class IngredientAddingForm extends StatefulWidget {
  final Ingredient? detectedIngredient;
  const IngredientAddingForm({super.key, this.detectedIngredient});

  @override
  State<IngredientAddingForm> createState() => _IngredientAddingFormState();
}

class _IngredientAddingFormState extends State<IngredientAddingForm> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IngredientAddBloc(
        detectedIngredient: widget.detectedIngredient,
      )..add(CategoriesAndUnitsFetched()),
      child: PlatformScaffold(
        appBar: getAppBarWidget(context, title: AppLocalizations.of(context)!.addToPatntry),
        body: MultiBlocListener(
          listeners: [
            BlocListener<IngredientAddBloc, IngredientAddState>(
              listenWhen: (prev, curr) =>
                  prev.createdIngredient != curr.createdIngredient && curr.createdIngredient != null,
              listener: (context, state) {
                context.read<PantryBloc>().add(
                      PantryItemAdded(
                        dto: CreatePantryItemDto(
                          ingridient: state.createdIngredient!,
                          quantity: double.parse(state.quantity!),
                          location: state.location!,
                          unit: state.categoriesAndUnits!.units.firstWhere((el) => el.id == state.unitId).name,
                          expirationDate: state.expirationDate!,
                        ),
                      ),
                    );
              },
            ),
            BlocListener<PantryBloc, PantryState>(
              listenWhen: (prev, curr) => prev.items != curr.items,
              listener: (context, state) {
                context.loaderOverlay.hide();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
          child: BlocBuilder<IngredientAddBloc, IngredientAddState>(
            buildWhen: (prev, curr) => prev.categoriesAndUnits != curr.categoriesAndUnits,
            builder: (context, state) {
              if (state.categoriesAndUnits == null) {
                return Center(
                  child: PlatformCircularProgressIndicator(
                    cupertino: (_, __) =>
                        CupertinoProgressIndicatorData(color: context.theme.appColors.green, radius: 16),
                  ),
                );
              }
              return SafeArea(
                child: LayoutBuilder(builder: (_, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (MediaQuery.of(context).viewInsets.bottom),
                      maxHeight: constraints.maxHeight - (MediaQuery.of(context).viewInsets.bottom),
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: CommonConstants.pagePadding,
                            right: CommonConstants.pagePadding,
                            top: 12,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              List<SelectFieldItem<int>> categories = state.categoriesAndUnits!.categories
                                  .map((el) => SelectFieldItem<int>(value: el.id, label: el.name))
                                  .toList();
                              List<SelectFieldItem<int>> units = state.categoriesAndUnits!.units
                                  .map((el) => SelectFieldItem<int>(value: el.id, label: el.name))
                                  .toList();
                              return Column(
                                children: [
                                  BlocBuilder<IngredientAddBloc, IngredientAddState>(
                                    buildWhen: (prev, curr) => prev.ingredientName != curr.ingredientName,
                                    builder: (context, state) {
                                      return IngredientSearchField(
                                        label: AppLocalizations.of(context)!.ingredient,
                                        bloc: context.read<IngredientAddBloc>(),
                                        displayValue: state.ingredientName,
                                        onChaged: (value) {
                                          if (value is Ingredient) {
                                            context.read<IngredientAddBloc>().add(
                                                  DataChanged(
                                                    selectedIngredient: Nullable.value(value),
                                                    ingredientName: value.name,
                                                    categoryId: value.category.id,
                                                    unitId: value.unit.id,
                                                    imageUrl: value.imageUrl,
                                                    query: '',
                                                  ),
                                                );
                                          } else {
                                            context.read<IngredientAddBloc>().add(
                                                  DataChanged(
                                                    ingredientName: value,
                                                    selectedIngredient: const Nullable.value(null),
                                                    query: '',
                                                  ),
                                                );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<IngredientAddBloc, IngredientAddState>(
                                    buildWhen: (prev, curr) =>
                                        prev.categoryId != curr.categoryId ||
                                        prev.selectedIngredient != curr.selectedIngredient,
                                    builder: (context, state) {
                                      return SelectField(
                                        label: AppLocalizations.of(context)!.category,
                                        selectedValue:
                                            categories.firstWhereOrNull((el) => el.value == state.categoryId) ??
                                                categories[0],
                                        isDisabled: state.selectedIngredient != null,
                                        items: categories,
                                        onChange: (value) =>
                                            context.read<IngredientAddBloc>().add(DataChanged(categoryId: value)),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth / 2 - 6,
                                        child: BlocBuilder<IngredientAddBloc, IngredientAddState>(
                                          buildWhen: (prev, curr) => prev.quantity != curr.quantity,
                                          builder: (context, state) {
                                            return TextFieldInput(
                                              label: AppLocalizations.of(context)!.quantity,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              initialText: state.quantity?.toString(),
                                              maxLength: 6,
                                              onChanged: (value) => context.read<IngredientAddBloc>().add(
                                                    DataChanged(
                                                      quantity: value != ''
                                                          ? Nullable.value(value)
                                                          : const Nullable.value(null),
                                                    ),
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth / 2 - 6,
                                        child: BlocBuilder<IngredientAddBloc, IngredientAddState>(
                                          buildWhen: (prev, curr) => prev.unitId != curr.unitId,
                                          builder: (context, state) {
                                            return SelectField(
                                              label: AppLocalizations.of(context)!.unit,
                                              selectedValue:
                                                  units.firstWhereOrNull((el) => el.value == state.unitId) ?? units[0],
                                              items: units,
                                              onChange: (value) =>
                                                  context.read<IngredientAddBloc>().add(DataChanged(unitId: value)),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<IngredientAddBloc, IngredientAddState>(
                                    buildWhen: (prev, curr) => prev.expirationDate != curr.expirationDate,
                                    builder: (_, state) {
                                      return DatePickerField(
                                        label: AppLocalizations.of(context)!.expDate,
                                        initialDate: state.expirationDate,
                                        firstDate: state.expirationDate != null && state.selectedIngredient != null
                                            ? DateTime.parse(state.expirationDate!)
                                            : DateTime.now(),
                                        onChange: (date) =>
                                            context.read<IngredientAddBloc>().add(DataChanged(expirationDate: date)),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<IngredientAddBloc, IngredientAddState>(
                                    buildWhen: (prev, curr) => prev.location != curr.location,
                                    builder: (context, state) {
                                      List<SelectFieldItem> locations = ingredientLocation
                                          .map((el) => SelectFieldItem(label: el, value: el))
                                          .toList();
                                      return SelectField(
                                        label: AppLocalizations.of(context)!.location,
                                        selectedValue: locations.firstWhereOrNull((el) => el.value == state.location) ??
                                            locations[0],
                                        items: locations,
                                        onChange: (value) =>
                                            context.read<IngredientAddBloc>().add(DataChanged(location: value)),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: CommonConstants.pagePadding,
                          right: CommonConstants.pagePadding,
                          child: BlocBuilder<IngredientAddBloc, IngredientAddState>(
                            builder: (context, state) {
                              return ActionButton(
                                text: AppLocalizations.of(context)!.add,
                                onPress: state.ingredientName == null ||
                                        state.quantity == null ||
                                        state.expirationDate == null
                                    ? null
                                    : () {
                                        context.loaderOverlay.show();
                                        if (state.selectedIngredient == null) {
                                          context.read<IngredientAddBloc>().add(IngredientCreated());
                                        } else {
                                          context.read<PantryBloc>().add(
                                                PantryItemAdded(
                                                  dto: CreatePantryItemDto(
                                                    ingridient: state.selectedIngredient!,
                                                    unit: state.categoriesAndUnits!.units
                                                        .firstWhere((el) => el.id == state.unitId)
                                                        .name,
                                                    quantity: double.parse(state.quantity!),
                                                    location: state.location!,
                                                    expirationDate: state.expirationDate!,
                                                  ),
                                                ),
                                              );
                                        }
                                      },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
