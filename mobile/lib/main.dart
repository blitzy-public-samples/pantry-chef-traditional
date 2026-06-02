import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/app.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:path_provider/path_provider.dart';

/// Flutter application entrypoint that bootstraps platform services,
/// persistent state, dependency injection, and the root widget.
///
/// Startup runs inside `runZonedGuarded` so uncaught async errors raised
/// during boot are routed to the zone error handler.
///
/// The boot sequence performs the following steps in order:
/// - Calls `WidgetsFlutterBinding.ensureInitialized()` to bind the
///   framework before async work.
/// - Preserves the native splash via `FlutterNativeSplash.preserve(...)`.
/// - Builds `HydratedBloc.storage` with `HydratedStorage.build(...)` rooted
///   at `getTemporaryDirectory()` for persisted BLoC state.
/// - Locks orientation to portrait via `setPreferredOrientations()`.
/// - Initializes the `get_it` service locator via `setupLocator()`.
/// - Launches the UI with `runApp(const App())`.
void main() {
  return runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getTemporaryDirectory(),
    );
    await setPreferredOrientations();
    await setupLocator();
    runApp(const App());
  }, (error, stack) {
    // Zone error handler: receives uncaught async errors raised during
    // startup and the app lifecycle.
    // KNOWN ISSUE: `print` is elevated to an error by `avoid_print` in
    // analysis_options.yaml; retained unchanged under the additive-only
    // documentation clause.
    print(error);
  });
}

/// Locks the application to portrait orientation.
///
/// Calls `SystemChrome.setPreferredOrientations` with
/// `DeviceOrientation.portraitUp` and `DeviceOrientation.portraitDown`,
/// and returns the `Future` that operation produces.
Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
