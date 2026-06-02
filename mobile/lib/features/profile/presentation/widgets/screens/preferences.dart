import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Preferences page shell (platform-adaptive scaffold).
///
/// Provides a localized, platform-adaptive page frame for the
/// preferences route. See the KNOWN ISSUE in [build] below.
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KNOWN ISSUE: This build returns a PlatformScaffold with only
    // an app bar (getAppBarWidget) and no `body` argument, so the
    // screen renders no content and is effectively empty. Captured
    // verbatim per the additive-only policy; no fix is applied.
    return PlatformScaffold(
      appBar: getAppBarWidget(
        context,
        title: AppLocalizations.of(context)!.preferences,
      ),
    );
  }
}
