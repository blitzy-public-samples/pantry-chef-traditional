import 'package:get_it/get_it.dart';
import 'package:pantry_chef/core/utils/dio_client.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide `get_it` service locator (`GetIt.instance`) and DI registry,
/// used to resolve shared singletons across the app.
///
/// Source: mobile/lib/core/utils/service_locator.dart:L6
final getIt = GetIt.instance;

/// Async dependency-injection bootstrap that registers the app's shared
/// singletons with `getIt` at startup.
///
/// Source: mobile/lib/core/utils/service_locator.dart:L8
///
/// Registers `SharedPreferences` as an async singleton.
/// Source: mobile/lib/core/utils/service_locator.dart:L9-L10
///
/// Then registers `SharedPreferencesHelper`, awaiting the resolved
/// `SharedPreferences` instance.
/// Source: mobile/lib/core/utils/service_locator.dart:L11-L12
///
/// Then registers `DioClient`, injecting the `SharedPreferencesHelper`.
/// Source: mobile/lib/core/utils/service_locator.dart:L13-L14
///
/// Registration ORDER matters: `DioClient` depends on
/// `SharedPreferencesHelper`, which depends on `SharedPreferences`, so the
/// three singletons must be registered in this sequence.
/// Source: mobile/lib/core/utils/service_locator.dart:L8-L15
///
/// Invoked during app startup from `main.dart`.
/// Source: mobile/lib/main.dart:L18
Future<void> setupLocator() async {
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingleton(
      SharedPreferencesHelper(await getIt.getAsync<SharedPreferences>()));
  getIt.registerSingleton(
      DioClient(sharedPrefHelper: getIt<SharedPreferencesHelper>()));
}
