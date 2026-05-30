import { ApiProperty } from '@nestjs/swagger';
import { Recipe } from '../domain/recipe';

export class MissingIngredientDto {
  @ApiProperty({ description: 'Ingredient identifier' })
  id: string;

  @ApiProperty({ description: 'Ingredient name' })
  name: string;
}

export class RecipeSuggestionDto {
  @ApiProperty({ type: Recipe })
  recipe: Recipe;

  @ApiProperty({ minimum: 0, maximum: 1 })
  matchScore: number;

  @ApiProperty({ enum: ['READY', 'ALMOST_THERE', 'MISSING'] })
  status: 'READY' | 'ALMOST_THERE' | 'MISSING';

  @ApiProperty()
  isQuickMake: boolean;

  @ApiProperty({ type: [MissingIngredientDto] })
  missingIngredients: MissingIngredientDto[];
}

export class RecipeSuggestionsResponseDto {
  @ApiProperty({ type: [RecipeSuggestionDto] })
  data: RecipeSuggestionDto[];

  @ApiProperty()
  hasMore: boolean;
}
