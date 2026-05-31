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

/// Application-layer use case that performs full logout teardown for the PantryChef mobile app.
///
/// Implements [UseCaseWithParams] (`void` result, [BuildContext] param) from
/// `package:pantry_chef/core/utils/usercase.dart` (filename typo preserved verbatim). A
/// [BuildContext] is required for provider scope and the Navigator; teardown runs in five steps:
///
/// 1. Server-side logout: instantiates [ProfileRepositiryImpl] (typo preserved verbatim) and
///    calls `repo.logout()` to invalidate the refresh session via `POST /api/v1/auth/logout`.
/// 2. Local credential cleanup: resolves [SharedPreferencesHelper] via
///    `getIt<SharedPreferencesHelper>()` (the only GetIt-resolved dependency here), then clears
///    both JWTs with `removeAccessToken()` and `removeRefreshToken()`.
/// 3. Sibling BLoC reset via `context.read<>()`: `PantryBloc` <- `PantryListReseted()`,
///    `RecipeBloc` <- `RecipeListReseted()`, `ProfileBloc` <- `ProfileDataReseted()`, and
///    `HomeBloc` <- `ActiveTabChannged(index: 0)` (`*Reseted` names and double-N preserved).
/// 4. Hydrated storage clear: `HydratedBloc.storage.clear()` wipes all persisted BLoC state.
/// 5. Navigation stack replacement: `Navigator.of(context).pushNamedAndRemoveUntil(
///    Navigation.authenticationStart, (_) => false)` replaces (it does not pop) the full stack;
///    the `(_) => false` predicate removes all prior routes so back navigation is impossible.
///
/// Precondition: the [BuildContext] MUST expose `PantryBloc`, `RecipeBloc`, `ProfileBloc`, and
/// `HomeBloc` providers (step 3) and stay valid through the final navigation call (step 5).
///
/// This DartDoc is the canonical, authoritative reference for the logout contract;
/// `mobile/lib/features/profile/README.md` § "Primary Use Cases" only summarizes it. See also
/// [ARCHITECTURE.md](../../../../../../ARCHITECTURE.md) § JWT Authentication Flow.
class LogoutUsecase implements UseCaseWithParams<void, BuildContext> {
  /// Executes the full logout teardown sequence described in the
  /// [LogoutUsecase] class-level DartDoc.
  ///
  /// Precondition: [context] must expose `PantryBloc`, `RecipeBloc`, `ProfileBloc`, and
  /// `HomeBloc` providers, and must stay valid through the final navigation call (step 5).
  ///
  /// Errors from the server-side logout (step 1) propagate up unhandled; steps 2-5 are not in a
  /// `try`/`finally`, so local cleanup is skipped if step 1 throws.
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
