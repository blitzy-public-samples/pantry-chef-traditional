import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/app.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/env_config.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  return runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // SECURITY(SEC-C3): Enforce HTTPS API base URL in release-mode builds
    EnvConfig.validate();
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

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
