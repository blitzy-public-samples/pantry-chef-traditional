/// Barrel exports for selected profile feature use cases.
///
/// Currently re-exports [GetProfileUsecase] and [LogoutUsecase]. Note that
/// [FavoriteRecipesUpdateUsecase] is intentionally NOT exported here — it is
/// imported directly by consumers (notably `ProfileBloc` in
/// `mobile/lib/features/profile/presentation/bloc/profile/profile_bloc.dart`).
///
/// The omission is deliberate: the barrel is curated to expose only stable,
/// broadly-consumed use cases. Future maintainers should NOT "fix" this by
/// adding the missing export.
export './get_profile.usecase.dart';
export './logout.usecase.dart';
