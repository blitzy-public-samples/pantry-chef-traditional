import 'package:pantry_chef/core/domain/models/app_language.dart';

/// The app's central registry of supported [AppLanguage]s.
///
///
/// Currently contains a single English entry
/// (`title: 'English', locale: 'en', code: 'en'`).
///
List<AppLanguage> availableLanguages = const [
  AppLanguage(title: 'English', locale: 'en', code: 'en'),
];
