import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/presentation/bloc/home/home_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/app_icon_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/ingredient/presentation/widgets/screens/ingredient_camera_detecting.dart';
import 'package:pantry_chef/features/pantry/presentation/widgets/screens/patry_main.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/profile/presentation/widgets/screens/profile_main.dart';
import 'package:pantry_chef/features/recipe/presentation/widgets/screens/recipe_main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    context.read<ProfileBloc>().add(ProfileFetched());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                toolbarHeight: CommonConstants.homeAppBarHeight,
                backgroundColor: context.theme.appColors.beige,
                surfaceTintColor: Colors.transparent,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: CommonConstants.pagePadding),
                child: SafeArea(
                  child: Builder(
                    builder: (_) {
                      switch (state.activeTabIndex) {
                        case 0:
                          return RecipeMain();
                        case 1:
                          return PantryMain();
                        default:
                          return ProfileMain();
                      }
                    },
                  ),
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.activeTabIndex,
                selectedItemColor: context.theme.appColors.green,
                items: [
                  BottomNavigationBarItem(
                    label: AppLocalizations.of(context)!.recipe,
                    icon: Icon(Icons.checklist),
                  ),
                  BottomNavigationBarItem(
                    label: AppLocalizations.of(context)!.pantry,
                    icon: Icon(Icons.shelves),
                  ),
                  BottomNavigationBarItem(
                    label: AppLocalizations.of(context)!.profile,
                    icon: Icon(Icons.man),
                  )
                ],
                onTap: (value) => context.read<HomeBloc>().add(ActiveTabChannged(index: value)),
              ),
              floatingActionButton: state.activeTabIndex == 1
                  ? AppIconButton(
                      icon: Icons.add,
                      onPress: () {
                        Navigator.of(context).push(
                          _createRoute(const IngredientCameraDetecting()),
                        );
                      },
                    )
                  : null);
        },
      ),
    );
  }
}

Route _createRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
