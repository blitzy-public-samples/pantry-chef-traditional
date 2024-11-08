import 'package:json_annotation/json_annotation.dart';

part 'recipe_filters.dto.g.dart';

@JsonSerializable()
class RecipeFiltersDto {
  final bool isQuickMake;
  final bool isAlmostThere;

  const RecipeFiltersDto({
    this.isQuickMake = false,
    this.isAlmostThere = false,
  });

  Map<String, dynamic> toJson() => _$RecipeFiltersDtoToJson(this);
}
