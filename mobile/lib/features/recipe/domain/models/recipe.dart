import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/recipe/domain/models/ingredient_list_item.dart';
import 'package:pantry_chef/features/recipe/domain/models/instraction_item.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String title;
  final String description;
  final List<IngredientListItem> ingridientList;
  final List<InstractionItem> instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final List<String> tags;
  final String imageUrl;
  final double? matchScore; // how well it matches available ingredients

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

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
