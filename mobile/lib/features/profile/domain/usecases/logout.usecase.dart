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

/// Use case that performs a complete sign-out for the current user.
///
/// Implements [UseCaseWithParams] over a [BuildContext]; clears the
/// session across the repository, local storage, feature BLoCs,
/// hydrated storage, and finally navigation.
class LogoutUsecase implements UseCaseWithParams<void, BuildContext> {
  /// Signs the user out using [context] to reach BLoCs and navigation.
  ///
  /// Runs repository logout, removes stored tokens, resets the pantry,
  /// recipe, profile, and home BLoCs, clears hydrated storage, and
  /// returns to the authentication entry route, clearing the stack.
  @override
  Future<void> call(BuildContext context) async {
    // Bind the misspelled impl to the correct interface type.
    ProfileRepository repo = ProfileRepositiryImpl();
    // Clear server-side / repository session state.
    await repo.logout();
    // Resolve the shared-preferences wrapper from the service locator.
    SharedPreferencesHelper sharedPreferencesHelper = getIt<SharedPreferencesHelper>();
    // Drop the persisted access and refresh tokens.
    await sharedPreferencesHelper.removeAccessToken();
    await sharedPreferencesHelper.removeRefreshToken();
    // Reset each feature BLoC to its initial, signed-out state.
    context.read<PantryBloc>().add(PantryListReseted());
    context.read<RecipeBloc>().add(RecipeListReseted());
    context.read<ProfileBloc>().add(ProfileDataReseted());
    // ActiveTabChannged (sic) resets the home tab to index 0.
    context.read<HomeBloc>().add(ActiveTabChannged(index: 0));
    // Clear persisted hydrated BLoC state (not awaited by design).
    HydratedBloc.storage.clear();
    // Return to the auth entry route and remove all prior routes.
    Navigator.of(context).pushNamedAndRemoveUntil(Navigation.authenticationStart, (_) => false);
  }
}
