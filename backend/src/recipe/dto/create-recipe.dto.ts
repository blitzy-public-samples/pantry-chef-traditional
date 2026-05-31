// NOTE: 'IngridientListDto' class and 'ingridientList' field name preserved
// verbatim. Do not rename.
import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumber,
  IsArray,
  IsIn,
  ValidateNested,
  IsUrl,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Validation contract for a single ingredient row inside a recipe's
 * `ingridientList` (spelling preserved verbatim throughout the backend
 * codebase). Validates the reference to the `Ingridient` domain entity,
 * the amount, the unit string, and the required/substitutes metadata.
 *
 * Used by both `CreateRecipeDto` and `UpdateRecipeDto` (via `PartialType`).
 */
export class IngridientListDto {
  @ApiProperty({ description: 'Ingredient reference' })
  @IsNotEmpty()
  ingridient: Ingridient;

  @ApiProperty({ description: 'Amount of the ingredient' })
  @IsNotEmpty()
  @IsNumber()
  amount: number;

  @ApiProperty({ description: 'Unit of measurement for the ingredient' })
  @IsNotEmpty()
  @IsString()
  unit: string;

  @ApiProperty({ description: 'Indicates if the ingredient is required' })
  @IsNotEmpty()
  required: boolean;

  @ApiProperty({
    description: 'Optional substitutes for the ingredient',
    required: false,
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  substitutes?: string[];
}

/**
 * Validation contract for a single cooking instruction step.
 *
 * Fields: `step` (1-indexed step number), `description` (step text), and
 * optional `timer` (minutes for an optional client-side timer UI).
 */
export class InstructionDto {
  @ApiProperty({ description: 'Step number in the instructions' })
  @IsNotEmpty()
  @IsNumber()
  step: number;

  @ApiProperty({ description: 'Description of the step' })
  @IsNotEmpty()
  @IsString()
  description: string;

  @ApiProperty({ description: 'Optional timer for the step', required: false })
  @IsOptional()
  @IsNumber()
  timer?: number;
}

/**
 * Validation contract for POST /api/v1/recipe.
 *
 * Validates required fields and the embedded `ingridientList` array
 * (spelling preserved verbatim throughout the backend codebase). Nested
 * arrays (`ingridientList` and `instructions`) are validated via
 * `@ValidateNested({ each: true })` and `@Type(() => ...)` to drive
 * class-transformer hydration. The `difficulty` field is constrained to
 * the union `'easy' | 'medium' | 'hard'`.
 */
export class CreateRecipeDto {
  @ApiProperty({ description: 'Title of the recipe' })
  @IsNotEmpty()
  @IsString()
  title: string;

  @ApiProperty({ description: 'Description of the recipe' })
  @IsNotEmpty()
  @IsString()
  description: string;

  @ApiProperty({
    description: 'List of ingredients with amounts, units, and substitutes',
    type: [IngridientListDto],
  })
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => IngridientListDto)
  ingridientList: IngridientListDto[];

  @ApiProperty({
    description: 'Cooking instructions with steps and optional timers',
    type: [InstructionDto],
  })
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InstructionDto)
  instructions: InstructionDto[];

  @ApiProperty({ description: 'Preparation time in minutes' })
  @IsNotEmpty()
  @IsNumber()
  prepTime: number;

  @ApiProperty({ description: 'Cooking time in minutes' })
  @IsNotEmpty()
  @IsNumber()
  cookTime: number;

  @ApiProperty({ description: 'Number of servings' })
  @IsNotEmpty()
  @IsNumber()
  servings: number;

  @ApiProperty({
    description: 'Difficulty level of the recipe',
    enum: ['easy', 'medium', 'hard'],
  })
  @IsNotEmpty()
  @IsIn(['easy', 'medium', 'hard'])
  difficulty: 'easy' | 'medium' | 'hard';

  @ApiProperty({
    description: 'Tags associated with the recipe',
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags: string[];

  @ApiProperty({ description: 'Image URL of the recipe', required: false })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

  @ApiProperty({
    description: 'Match score for recommendation engines',
    required: false,
    minimum: 0,
    maximum: 1,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  matchScore?: number;
}
