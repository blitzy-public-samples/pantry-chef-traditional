part of 'profile_bloc.dart';

/// Sealed base class for all events handled by [ProfileBloc].
///
/// Extends [Equatable] so events compare by value rather than identity, which
/// keeps duplicate dispatches from triggering unnecessary state rebuilds.
sealed class ProfileEvent extends Equatable {
  /// Creates a [ProfileEvent] (const so subclasses can be const-constructed).
  const ProfileEvent();

  /// [Equatable] props for value equality (empty by default).
  @override
  List<Object> get props => [];
}

/// Event dispatched to fetch the current user profile.
///
/// Triggers [GetProfileUsecase], which calls `GET /api/v1/auth/me` and emits
/// the resulting [Profile] into [ProfileState.userProfile].
class ProfileFetched extends ProfileEvent {}

/// Event dispatched to load full [Recipe] objects for `favoriteRecipes` IDs.
///
/// Reads the persisted ID list from `state.userProfile!.favoriteRecipes`,
/// calls [GetFavoriteRecipeListUsecase], and emits the resolved
/// `List<Recipe>` into [ProfileState.favoriteRecipes]. If the ID list is
/// empty, the handler short-circuits with an empty list and no API call.
class FavoriteRecipesFetched extends ProfileEvent {}

/// Event dispatched when the user toggles a recipe favorite.
///
/// Carries the [recipeId] of the target recipe and the desired [isFavorite]
/// state. Triggers [FavoriteRecipesUpdateUsecase] which updates the
/// server-side `User.favoriteRecipes` and (when adding) fetches the newly
/// added [Recipe] so it can be prepended to [ProfileState.favoriteRecipes].
class FavoriteRecipesListUpdated extends ProfileEvent {
  /// The ID of the recipe whose favorite status is being toggled.
  final String recipeId;

  /// `true` to add the recipe to favorites; `false` to remove it.
  final bool isFavorite;

  /// Creates a [FavoriteRecipesListUpdated] with [recipeId] and [isFavorite].
  const FavoriteRecipesListUpdated({required this.recipeId, required this.isFavorite});

  /// [Equatable] props using [recipeId] and [isFavorite].
  @override
  List<Object> get props => [recipeId, isFavorite];
}

/// Event dispatched when the user taps logout.
///
/// Carries a [BuildContext] used by [LogoutUsecase] for sibling-BLoC resets
/// (`context.read<PantryBloc>()`, `RecipeBloc`, `ProfileBloc`, `HomeBloc`)
/// and for triggering `Navigator.pushNamedAndRemoveUntil` to the auth start
/// route. Carrying a [BuildContext] inside an event is unusual but
/// intentional in this codebase; do not refactor it without coordinating
/// with [LogoutUsecase].
class Logout extends ProfileEvent {
  /// The [BuildContext] used by [LogoutUsecase] for sibling-BLoC `context.read`
  /// calls and for `Navigator.pushNamedAndRemoveUntil`.
  final BuildContext context;

  /// Creates a [Logout] event carrying the [context] required by
  /// [LogoutUsecase].
  const Logout({required this.context});

  /// [Equatable] props (the [context] reference).
  @override
  List<Object> get props => [context];
}

/// Event dispatched to reset [ProfileState] to its empty default.
///
/// Used as part of the logout teardown by [LogoutUsecase] and may also be
/// dispatched directly to clear profile state without contacting the backend.
class ProfileDataReseted extends ProfileEvent {}
