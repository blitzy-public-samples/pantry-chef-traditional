part of 'profile_bloc.dart';

/// Immutable state for [ProfileBloc] holding the current user profile
/// and the loaded list of favorite recipes.
class ProfileState extends Equatable {
  /// The current user's profile, or null until [ProfileFetched] loads it.
  final Profile? userProfile;
  /// The loaded favorite recipes, or null until they are fetched.
  final List<Recipe>? favoriteRecipes;

  const ProfileState({
    this.userProfile,
    this.favoriteRecipes,
  });

  @override
  List<Object?> get props => [userProfile, favoriteRecipes];

  /// Returns a new [ProfileState], replacing [userProfile] and/or
  /// [favoriteRecipes] when provided, else keeping current values via
  /// `?? this.<field>`.
  ProfileState copyWith({
    final Profile? userProfile,
    final List<Recipe>? favoriteRecipes,
  }) =>
      ProfileState(
        userProfile: userProfile ?? this.userProfile,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      );
}
