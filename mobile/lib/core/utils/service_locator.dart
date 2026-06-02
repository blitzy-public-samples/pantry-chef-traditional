import 'package:get_it/get_it.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide `get_it` service locator (`GetIt.instance`) and DI registry,
/// used to resolve shared singletons across the app.
///
final getIt = GetIt.instance;

/// Async dependency-injection bootstrap that registers the app's shared
/// singletons with `getIt` at startup.
///
///
/// Registers `SharedPreferences` as an async singleton.
///
/// Then registers `SharedPreferencesHelper`, awaiting the resolved
/// `SharedPreferences` instance.
///
/// Then registers `DioClient`, injecting the `SharedPreferencesHelper`.
///
/// Registration ORDER matters: `DioClient` depends on
/// `SharedPreferencesHelper`, which depends on `SharedPreferences`, so the
/// three singletons must be registered in this sequence.
///
/// Invoked during app startup from `main.dart`.
/// Source: mobile/lib/main.dart:L33
Future<void> setupLocator() async {
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingleton(
      SharedPreferencesHelper(await getIt.getAsync<SharedPreferences>()));
  getIt.registerSingleton(
      DioClient(sharedPrefHelper: getIt<SharedPreferencesHelper>()));
}
