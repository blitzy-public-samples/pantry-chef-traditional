import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/recipe/domain/models/ingredient_list_item.dart';
import 'package:pantry_chef/features/recipe/domain/models/instraction_item.dart';

part 'recipe.g.dart';

/// Immutable, JSON-serializable recipe aggregate model.
///
/// Composes typed ingredient line items ([IngredientListItem]) and
/// ordered instruction steps ([InstractionItem], a preserved sic name).
/// JSON conversion is delegated to generated code via
/// `part 'recipe.g.dart'`.
@JsonSerializable()
class Recipe {
  /// Unique recipe identifier.
  final String id;
  /// Recipe display title.
  final String title;
  /// Short recipe description.
  final String description;
  /// Typed ingredient line items; the field name spelling
  /// 'ingridientList' (sic) is intentional and preserved.
  final List<IngredientListItem> ingridientList;
  /// Ordered instruction steps; the element type
  /// 'InstractionItem' (sic) is a preserved spelling.
  final List<InstractionItem> instructions;
  /// Preparation time in minutes.
  final int prepTime;
  /// Cooking time in minutes.
  final int cookTime;
  /// Number of servings.
  final int servings;
  /// Difficulty label (free-form String).
  final String difficulty;
  /// Descriptive tags.
  final List<String> tags;
  /// Recipe image URL.
  final String imageUrl;
  /// Optional match score for ingredient-based matching;
  /// null when the recipe is not part of a match result.
  final double? matchScore; // how well it matches available ingredients

  // Const constructor; all fields except matchScore are required.
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

  // KNOWN ISSUE: copyWith({final bool? inFavorite}) accepts
  // [inFavorite] but never applies it. Recipe has no
  // inFavorite field, so this returns an identical copy
  // (a no-op).
  /// Returns a copy of this recipe. [inFavorite] is accepted
  /// for call-site compatibility but is currently unused.
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

  /// Creates a [Recipe] from a JSON map [json].
  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  /// Converts this [Recipe] to a JSON map.
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
