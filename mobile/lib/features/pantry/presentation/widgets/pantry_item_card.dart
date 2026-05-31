import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/app_icon_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Reusable, stateless Material card widget rendering a single [PantryItem].
///
/// Formats `expirationDate` via `intl.DateFormat('dd.MM.yyyy')` and shows the
/// quantity with the ingredient's unit name. The card embeds an edit
/// [AppIconButton] (Source:
/// `mobile/lib/core/presentation/widgets/app_icon_button.dart`) that navigates
/// to [Navigation.pantryItemEdit] (Source:
/// `mobile/lib/core/constants/navigation.dart:L11`) and passes the current
/// item as the route `arguments`.
///
/// Note: `item.ingridient.name` and `item.ingridient.unit.name` use the
/// preserved-verbatim `ingridient` spelling that mirrors the backend
/// `PantryIngridient` schema (spelling preserved verbatim).
class PantryItemCard extends StatelessWidget {
  /// The [PantryItem] rendered by this card.
  ///
  /// Provides:
  /// * `item.ingridient.name` — ingredient display name (spelling preserved).
  /// * `item.ingridient.unit.name` — unit display name (spelling preserved).
  /// * `item.quantity` — numeric quantity shown next to the unit.
  /// * `item.expirationDate` — ISO-8601 string parsed via `DateTime.parse`
  ///   and formatted with `DateFormat('dd.MM.yyyy')`.
  /// * `item.id` — passed as `arguments` to [Navigation.pantryItemEdit] when
  ///   the user taps the edit affordance.
  final PantryItem item;

  /// Const constructor.
  ///
  /// Requires the [PantryItem] to render via the [item] field.
  const PantryItemCard({super.key, required this.item});

  /// Builds the Material card layout.
  ///
  /// The widget tree consists of a transparent [Material] wrapper around an
  /// elevated [Card], with a padded [Column] containing:
  ///
  /// 1. A header [Row] holding the ingredient name (`item.ingridient.name`,
  ///    spelling preserved) on the left and an edit [AppIconButton] on the
  ///    right. The button calls
  ///    `Navigator.of(context).pushNamed(Navigation.pantryItemEdit,`
  ///    `arguments: item)` to open the per-item edit screen.
  /// 2. An expiration-date row formatted via `DateFormat('dd.MM.yyyy')`.
  /// 3. A quantity row showing `item.quantity` followed by
  ///    `item.ingridient.unit.name` (spelling preserved).
  ///
  /// Localized labels are read from [AppLocalizations] and theme tokens are
  /// resolved through the `context.theme.appColors` / `appTextTheme`
  /// extensions defined in `mobile/lib/core/styles/app_theme.dart`.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Card(
        elevation: 1,
        color: context.theme.appColors.white,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.ingridient.name,
                    style: context.theme.appTextTheme.semiBold14,
                  ),
                  AppIconButton(
                    icon: Icons.edit,
                    padding: EdgeInsets.all(0),
                    iconSize: 18,
                    backgroundColor: Colors.transparent,
                    onPress: () {
                      Navigator.of(context).pushNamed(Navigation.pantryItemEdit, arguments: item);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${AppLocalizations.of(context)!.expirationDate}: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(item.expirationDate))}',
                style: context.theme.appTextTheme.regular14,
              ),
              const SizedBox(height: 2),
              Text(
                '${AppLocalizations.of(context)!.quantity}: ${item.quantity} ${item.ingridient.unit.name}',
                style: context.theme.appTextTheme.regular14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
