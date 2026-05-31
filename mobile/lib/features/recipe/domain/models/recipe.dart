import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/recipe/domain/models/ingredient_list_item.dart';
// NOTE: 'instraction_item.dart' filename and 'InstractionItem' class are preserved
// verbatim. Do not rename.
import 'package:pantry_chef/features/recipe/domain/models/instraction_item.dart';

part 'recipe.g.dart';

/// Domain model for a single recipe.
///
/// Mirrors the backend `RecipeSchemaClass` (see `DATA_MODEL.md` § Recipe).
/// Includes `ingridientList` (spelling preserved verbatim) and
/// `instructions: List<InstractionItem>` (spelling preserved verbatim), and
/// an optional `matchScore` populated only by `/api/v1/recipe/matches`
/// responses.
@JsonSerializable()
class Recipe {
  /// Mongo `_id` from the backend; used by `RecipeBloc.RecipeDetailedSelected` to look up
  /// the recipe in state.
  final String id;

  /// Recipe title; indexed on the backend collection.
  final String title;

  /// Free-text description; rendered in `RecipeCard` (3 lines, ellipsis) and `RecipeDetailed`.
  final String description;

  // NOTE: 'ingridientList' field name preserved verbatim (matches backend Recipe schema).
  /// Ingredients required to make this recipe.
  ///
  /// Field name preserved verbatim from backend Recipe schema (`ingridientList`).
  /// Each item is an `IngredientListItem` whose `ingridient` field (lowercase, sic)
  /// carries the `Ingredient` reference.
  final List<IngredientListItem> ingridientList;

  // NOTE: 'InstractionItem' spelling preserved verbatim (class in instraction_item.dart).
  /// Ordered cooking steps.
  ///
  /// The type name `InstractionItem` is preserved verbatim from backend
  /// (defined in `instraction_item.dart`).
  final List<InstractionItem> instructions;

  /// Prep time in minutes.
  final int prepTime;

  /// Cook time in minutes.
  final int cookTime;

  /// Number of servings the recipe yields.
  final int servings;

  /// Difficulty enum: `easy`, `medium`, or `hard` (validated server-side).
  final String difficulty;

  /// Searchable tags such as dietary classifications, cuisine, or category.
  final List<String> tags;

  /// Recipe hero image URL; consumed by `cached_network_image` via `ImageWidget`
  /// in `RecipeCard`.
  final String imageUrl;

  /// Server-derived match score in [0.0, 1.0] = `availableIngredients / totalIngredients`.
  ///
  /// Populated ONLY by `/api/v1/recipe/matches`. Null on regular list/detail responses.
  final double? matchScore; // how well it matches available ingredients

  /// Creates a `Recipe` with all required fields; `matchScore` is optional.
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingridientList,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.tags,
    required this.imageUrl,
    this.matchScore,
  });

  // NOTE: copyWith accepts an inFavorite parameter but does NOT use it.
  // Recipe has no inFavorite field.
  // FIXME: inFavorite is unused. Document only; do not fix. See PRODUCTION_READINESS.md.
  /// Returns a new `Recipe` with overridden fields.
  ///
  /// **NOTE:** the `inFavorite` parameter is currently accepted but ignored — `Recipe`
  /// has no `inFavorite` field. See the `// FIXME:` annotation above this method and
  /// `mobile/lib/features/recipe/README.md` § Known Limitations. Favorites are managed
  /// in `User.favoriteRecipes` via `ProfileBloc`.
  Recipe copyWith({
    final bool? inFavorite,
  }) =>
      Recipe(
        id: id,
        title: title,
        description: description,
        ingridientList: ingridientList,
        instructions: instructions,
        prepTime: prepTime,
        cookTime: cookTime,
        servings: servings,
        difficulty: difficulty,
        tags: tags,
        imageUrl: imageUrl,
        matchScore: matchScore,
      );

  /// Deserializes from the canonical JSON shape via the json_serializable-generated factory.
  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  /// Serializes to the canonical JSON shape.
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
