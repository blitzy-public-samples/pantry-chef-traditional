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

  // Added for QA FINAL Issue #2: an explicit pantry-empty signal. The API still
  // returns the (score-0) ranked recipes for an empty pantry per AAP §0.4.2.1,
  // but the mobile suggestions screen needs to know the pantry is empty so it
  // can render the "Add items to your pantry to get suggestions." empty state
  // instead of a list of all-missing cards. True when the user has zero pantry
  // items at request time.
  @ApiProperty({
    description:
      'True when the requesting user has no pantry items; the client renders the empty-pantry guidance state in this case.',
  })
  isPantryEmpty: boolean;
}
