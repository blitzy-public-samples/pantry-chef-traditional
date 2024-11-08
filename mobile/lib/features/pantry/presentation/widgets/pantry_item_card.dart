import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/app_icon_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PantryItemCard extends StatelessWidget {
  final PantryItem item;

  const PantryItemCard({super.key, required this.item});

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
