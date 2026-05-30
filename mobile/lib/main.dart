import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/app.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:path_provider/path_provider.dart';

/// Application entry point that bootstraps the Flutter widget tree.
///
/// Runs inside [runZonedGuarded] so any top-level asynchronous error during
/// startup is captured and logged rather than crashing the isolate. The
/// startup sequence is, in order:
/// 1. `WidgetsFlutterBinding.ensureInitialized()` to bind the engine.
/// 2. `FlutterNativeSplash.preserve(...)` to hold the native splash screen
///    until the first frame can be rendered.
/// 3. Build [HydratedBloc.storage] backed by the OS temporary directory so
///    persisted blocs (pantry, profile, favorite recipes) survive restarts.
/// 4. Lock orientation to portrait via [setPreferredOrientations].
/// 5. Register dependencies via `setupLocator()` (GetIt service locator).
/// 6. Launch the UI with `runApp(const App())`.
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
    print(error);
  });
}

/// Locks the app to portrait orientation (both `portraitUp` and `portraitDown`).
///
/// Called once during bootstrap in [main]. Returns the [Future] from
/// `SystemChrome.setPreferredOrientations` so the caller can `await` it before
/// registering further startup tasks.
Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
