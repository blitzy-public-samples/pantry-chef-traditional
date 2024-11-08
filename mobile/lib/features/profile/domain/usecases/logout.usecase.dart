import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/bloc/home/home_bloc.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/core/utils/shared_preferences_helper.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/presentation/bloc/pantry/pantry_bloc.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';
import 'package:pantry_chef/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pantry_chef/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';

class LogoutUsecase implements UseCaseWithParams<void, BuildContext> {
  @override
  Future<void> call(BuildContext context) async {
    ProfileRepository repo = ProfileRepositiryImpl();
    await repo.logout();
    SharedPreferencesHelper sharedPreferencesHelper = getIt<SharedPreferencesHelper>();
    await sharedPreferencesHelper.removeAccessToken();
    await sharedPreferencesHelper.removeRefreshToken();
    context.read<PantryBloc>().add(PantryListReseted());
    context.read<RecipeBloc>().add(RecipeListReseted());
    context.read<ProfileBloc>().add(ProfileDataReseted());
    context.read<HomeBloc>().add(ActiveTabChannged(index: 0));
    HydratedBloc.storage.clear();
    Navigator.of(context).pushNamedAndRemoveUntil(Navigation.authenticationStart, (_) => false);
  }
}
