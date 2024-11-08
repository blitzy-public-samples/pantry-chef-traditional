class FavoriteRecipesUpdateDto {
  final List<String> favoriteList;
  final String? addedId;

  const FavoriteRecipesUpdateDto({
    required this.favoriteList,
    this.addedId,
  });
}
