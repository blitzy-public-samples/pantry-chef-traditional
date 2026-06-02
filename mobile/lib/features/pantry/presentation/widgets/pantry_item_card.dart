import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/app_icon_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Stateless Material card that renders a single pantry [item].
///
/// Shows the ingredient name, the expiration date formatted as
/// `dd.MM.yyyy`, and the quantity with its unit. Provides an edit
/// affordance that routes to [Navigation.pantryItemEdit], passing
/// the [item] as route arguments.
class PantryItemCard extends StatelessWidget {
  /// The [item] (`PantryItem`) rendered by this card.
  final PantryItem item;

  const PantryItemCard({super.key, required this.item});

  /// Builds the pantry item card for the given [context].
  ///
  /// Renders the ingredient name, the expiration date formatted as
  /// `dd.MM.yyyy`, and the quantity with its unit, plus an edit button
  /// that routes to [Navigation.pantryItemEdit].
  @override
  Widget build(BuildContext context) {
    // Transparent Material wrapper so the Card defines the surface.
    return Material(
      color: Colors.transparent,
      // Lightly elevated white Card with a transparent rounded border.
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
              // Header row: ingredient name and edit affordance.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.ingridient.name,
                    style: context.theme.appTextTheme.semiBold14,
                  ),
                  // Edit button opens the pantry item edit screen,
                  // passing the current item as navigation arguments.
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
              // Expiration date label formatted as dd.MM.yyyy.
              Text(
                '${AppLocalizations.of(context)!.expirationDate}: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(item.expirationDate))}',
                style: context.theme.appTextTheme.regular14,
              ),
              const SizedBox(height: 2),
              // Quantity label with the ingredient's unit name.
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
