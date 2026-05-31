import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/app.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  return runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    // QA FINAL Issue #3: on Flutter web `getTemporaryDirectory()` (path_provider)
    // has no implementation and throws a MissingPluginException before runApp,
    // leaving a blank page. Use HydratedBloc's built-in web storage location on
    // web and the temporary directory on native platforms so the app boots on
    // both. (kIsWeb is provided by package:flutter/foundation, re-exported via
    // material.dart.)
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getTemporaryDirectory(),
    );
    await setPreferredOrientations();
    await setupLocator();
    runApp(const App());
  }, (error, stack) {
    print(error);
  });
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
