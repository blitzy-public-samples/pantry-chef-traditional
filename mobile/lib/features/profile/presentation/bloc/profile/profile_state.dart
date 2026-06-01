part of 'profile_bloc.dart';

/// Immutable state held by [ProfileBloc].
///
/// Persisted across app launches via [HydratedMixin] (serialized through
/// [ProfileBloc.fromJson] and [ProfileBloc.toJson]). Both fields are
/// nullable so the state can distinguish "not yet loaded" (`null`) from
/// "loaded but empty" (e.g., `favoriteRecipes: []`).
class ProfileState extends Equatable {
  /// The current user's [Profile].
  ///
  /// `null` until the first [ProfileFetched] succeeds or after a
  /// [ProfileDataReseted] event resets the state.
  final Profile? userProfile;
  /// The full [Recipe] objects materialized from `userProfile.favoriteRecipes`.
  ///
  /// `null` until lazily fetched by a [FavoriteRecipesFetched] dispatch
  /// (typically from the `FavoriteRecipes` screen's `BlocBuilder` when it
  /// detects this field is `null`).
  final List<Recipe>? favoriteRecipes;

  /// Creates an immutable [ProfileState] with optional [userProfile] and
  /// [favoriteRecipes].
  const ProfileState({
    this.userProfile,
    this.favoriteRecipes,
  });

  /// [Equatable] props for value equality across [userProfile] and
  /// [favoriteRecipes].
  @override
  List<Object?> get props => [userProfile, favoriteRecipes];

  /// Returns a new [ProfileState] with selected fields replaced.
  ///
  /// Uses the copy-with-named-optional-parameters pattern: passing `null`
  /// (or omitting the argument) falls back to the current value rather than
  /// overwriting with null. To clear a field, emit a fresh `ProfileState()`
  /// (typically via [ProfileDataReseted]) instead of calling [copyWith].
  ProfileState copyWith({
    final Profile? userProfile,
    final List<Recipe>? favoriteRecipes,
  }) =>
      ProfileState(
        userProfile: userProfile ?? this.userProfile,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      );
}
