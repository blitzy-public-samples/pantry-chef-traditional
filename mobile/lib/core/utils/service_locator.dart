import 'package:get_it/get_it.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global [GetIt] service locator singleton for the PantryChef mobile app.
///
/// Feature code resolves dependencies via `getIt<Type>()` (synchronous, for
/// already-registered singletons) or `getIt.getAsync<Type>()` (asynchronous,
/// for `registerSingletonAsync` registrations such as [SharedPreferences]).
/// The singletons wired up by [setupLocator] are [SharedPreferences],
/// [SharedPreferencesHelper], and [DioClient].
///
/// Source: `mobile/lib/core/utils/service_locator.dart:L16`. See
/// [ARCHITECTURE.md](../../../../ARCHITECTURE.md) § GetIt Dependency Injection.
final getIt = GetIt.instance;

/// Application dependency wiring entry point for the GetIt service locator.
///
/// Invoked exactly once during app bootstrap from `mobile/lib/main.dart:L31`
/// (`await setupLocator();`), immediately before `runApp(const App())`. Feature
/// widgets built inside `runApp` resolve dependencies through [getIt], so every
/// singleton below must be registered before the UI starts.
///
/// The registration order is BINDING — reordering it breaks the startup chain:
///
/// 1. [SharedPreferences] is registered as an async singleton via
///    `SharedPreferences.getInstance()` (which returns a `Future`); it must
///    resolve before the helper can be constructed.
/// 2. [SharedPreferencesHelper] is registered as a sync singleton; it awaits the
///    async [SharedPreferences] singleton inline via
///    `getIt.getAsync<SharedPreferences>()` and wraps it. Awaiting here is what
///    lets the remaining registrations use the synchronous `registerSingleton`.
/// 3. [DioClient] is registered as a sync singleton; it resolves
///    [SharedPreferencesHelper] synchronously via `getIt<SharedPreferencesHelper>()`
///    for JWT token access in its request/refresh interceptor chain.
///
/// Source: `mobile/lib/core/utils/service_locator.dart:L39-L46`.
Future<void> setupLocator() async {
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingleton(
      SharedPreferencesHelper(await getIt.getAsync<SharedPreferences>()));
  getIt.registerSingleton(
      DioClient(sharedPrefHelper: getIt<SharedPreferencesHelper>()));
}
