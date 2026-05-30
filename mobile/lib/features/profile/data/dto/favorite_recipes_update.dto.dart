/// Plain DTO used by `FavoriteRecipesUpdateUsecase` to package an updated
/// favorites list together with the ID of any newly-added recipe.
///
/// Unlike [ProfileUpdateDto], this class is NOT `@JsonSerializable` and
/// does not expose a `toJson` method — it is consumed entirely on the
/// client side by the usecase, which fetches the full [Recipe] for any
/// newly-added id and forwards only the updated list to the server via
/// [ProfileRepository.updateFavoriteRecipesList].
class FavoriteRecipesUpdateDto {
  /// The full updated list of favorite recipe IDs to persist to the backend.
  final List<String> favoriteList;

  /// If a recipe was added (not removed), carries its ID so the usecase can
  /// fetch the full [Recipe] for display; `null` when the operation removed
  /// a favorite.
  final String? addedId;

  /// Creates a [FavoriteRecipesUpdateDto].
  const FavoriteRecipesUpdateDto({
    required this.favoriteList,
    this.addedId,
  });
}
