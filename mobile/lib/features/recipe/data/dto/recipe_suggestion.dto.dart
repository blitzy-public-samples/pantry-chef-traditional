import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';

part 'recipe_suggestion.dto.g.dart';

@JsonSerializable()
class MissingIngredientDto {
  final String id;
  final String name;

  const MissingIngredientDto({
    required this.id,
    required this.name,
  });

  factory MissingIngredientDto.fromJson(Map<String, dynamic> json) =>
      _$MissingIngredientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MissingIngredientDtoToJson(this);
}

@JsonSerializable()
class RecipeSuggestionDto {
  final Recipe recipe;
  final double matchScore;
  final String status;
  final bool isQuickMake;
  final List<MissingIngredientDto> missingIngredients;

  const RecipeSuggestionDto({
    required this.recipe,
    required this.matchScore,
    required this.status,
    required this.isQuickMake,
    required this.missingIngredients,
  });

  factory RecipeSuggestionDto.fromJson(Map<String, dynamic> json) =>
      _$RecipeSuggestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeSuggestionDtoToJson(this);
}

@JsonSerializable()
class RecipeSuggestionsResponseDto {
  final List<RecipeSuggestionDto> data;
  final bool hasMore;

  const RecipeSuggestionsResponseDto({
    required this.data,
    required this.hasMore,
  });

  factory RecipeSuggestionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RecipeSuggestionsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeSuggestionsResponseDtoToJson(this);
}
