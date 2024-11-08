part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final Profile? userProfile;
  final List<Recipe>? favoriteRecipes;

  const ProfileState({
    this.userProfile,
    this.favoriteRecipes,
  });

  @override
  List<Object?> get props => [userProfile, favoriteRecipes];

  ProfileState copyWith({
    final Profile? userProfile,
    final List<Recipe>? favoriteRecipes,
  }) =>
      ProfileState(
        userProfile: userProfile ?? this.userProfile,
        favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      );
}
