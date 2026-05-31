import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// User preferences screen (currently a stub).
///
/// Reached via `Navigation.preferences` from [ProfileMain]. The current
/// implementation contains only a [PlatformScaffold] with an app bar titled
/// "Preferences" via `AppLocalizations.of(context)!.preferences` — no edit UI
/// is wired yet. Future work should add fields for dietary preferences,
/// allergies, disliked ingredients, and cooking time (mirroring the backend's
/// embedded `Preferences` subdocument), but that is tracked elsewhere and is
/// not implemented in this widget today.
class PreferencesScreen extends StatelessWidget {
  /// Creates the [PreferencesScreen].
  const PreferencesScreen({super.key});

  /// Builds the (stub) preferences screen with a title-only app bar.
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: getAppBarWidget(
        context,
        title: AppLocalizations.of(context)!.preferences,
      ),
    );
  }
}
