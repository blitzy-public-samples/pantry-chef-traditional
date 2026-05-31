import 'package:pantry_chef/core/domain/models/app_language.dart';

/// The app's central registry of supported [AppLanguage]s.
///
/// Source: mobile/lib/core/utils/available_languages.dart:L3
///
/// Currently contains a single English entry
/// (`title: 'English', locale: 'en', code: 'en'`).
///
/// Source: mobile/lib/core/utils/available_languages.dart:L4
List<AppLanguage> availableLanguages = const [
  AppLanguage(title: 'English', locale: 'en', code: 'en'),
];
