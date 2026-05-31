/// Minimal immutable value object for a favorite-recipes update.
///
/// Carries the full updated set of favorite recipe ids and,
/// optionally, the single id newly added in this operation. Plain
/// Dart (not `@JsonSerializable`); has no generated companion file.
class FavoriteRecipesUpdateDto {
  /// Full updated set of favorite recipe ids (required).
  final List<String> favoriteList;
  /// Id newly added to favorites in this update, if any.
  final String? addedId;

  const FavoriteRecipesUpdateDto({
    required this.favoriteList,
    this.addedId,
  });
}
