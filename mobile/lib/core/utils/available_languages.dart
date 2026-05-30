import 'package:pantry_chef/core/domain/models/app_language.dart';

/// Central registry of the locales the Pantry Chef app officially supports.
///
/// Holds a single entry today, English (`en`), and is the source of truth for
/// the languages the app advertises: the root `MaterialApp` maps it to
/// `supportedLocales` and defaults the active locale to the first entry
/// (`availableLanguages[0]`). See `core/presentation/widgets/app.dart`.
///
/// Adding a language needs THREE coordinated changes — appending an entry here
/// alone is necessary but not sufficient (the locale would be advertised, but
/// its strings would fall back to English):
/// 1. Append an `AppLanguage(title, locale, code)` entry to this list.
/// 2. Register the locale for `flutter_localizations` codegen via
///    `mobile/i10n.yaml` (it reads ARB templates from `lib/l10n`).
/// 3. Add translated strings under `mobile/lib/l10n/` for the new locale.
///
/// Mutability caveat: only the list literal is `const`; the variable itself is
/// neither `const` nor `final`, so the reference can technically be reassigned
/// at runtime. Treat it as immutable shared reference data — do not mutate or
/// reassign it.
///
/// Each element is an [AppLanguage] value object.
List<AppLanguage> availableLanguages = const [
  AppLanguage(title: 'English', locale: 'en', code: 'en'),
];
