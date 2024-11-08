import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/navigation.dart';
import 'package:pantry_chef/core/presentation/bloc/home/home_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/home.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/core/utils/available_languages.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:pantry_chef/features/authentication/presentation/widgets/screens/authentication_start.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/features/pantry/presentation/bloc/pantry/pantry_bloc.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final SharedPreferencesHelper _sharedPrefsHelper = getIt<SharedPreferencesHelper>();

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
        BlocProvider(
          create: (context) => RecipeBloc(),
        ),
        BlocProvider(
          create: (context) => PantryBloc(),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(),
          lazy: false,
        ),
      ],
      child: PlatformProvider(
        builder: (context) => PlatformTheme(
          themeMode: ThemeMode.light,
          materialLightTheme: AppTheme.light,
          cupertinoLightTheme: CupertinoThemeData(
            scaffoldBackgroundColor: context.theme.appColors.beige,
            barBackgroundColor: context.theme.appColors.darkBeige,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: context.theme.appTextTheme.regular16,
            ),
            brightness: Brightness.light,
          ),
          builder: (_) => GlobalLoaderOverlay(
            child: PlatformApp(
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: child,
                );
              },
              title: CommonConstants.appName,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: availableLanguages.map((el) => Locale(el.locale)),
              locale: Locale(availableLanguages[0].locale),
              onGenerateRoute: (RouteSettings settings) {
                return onGenerateRoute(context, settings);
              },
              home: Builder(
                builder: (_) {
                  if (_sharedPrefsHelper.accessToken == null) {
                    return const AuthenticationStart();
                  }
                  return const Home();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
