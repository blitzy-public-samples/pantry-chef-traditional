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
 * Describes a single ingredient entry within a recipe payload.
 *
 * Note: the class name `IngridientListDto` and the `ingridient` field below
 * keep their original (misspelled) spelling and must not be renamed.
 */
export class IngridientListDto {
  // Referenced ingredient; typed as the Ingridient domain entity (spelling preserved).
  @ApiProperty({ description: 'Ingredient reference' })
  @IsNotEmpty()
  ingridient: Ingridient;

  // Quantity of the ingredient (numeric).
  @ApiProperty({ description: 'Amount of the ingredient' })
  @IsNotEmpty()
  @IsNumber()
  amount: number;

  // Unit of measurement for the amount.
  @ApiProperty({ description: 'Unit of measurement for the ingredient' })
  @IsNotEmpty()
  @IsString()
  unit: string;

  // Whether the ingredient is required for the recipe.
  @ApiProperty({ description: 'Indicates if the ingredient is required' })
  @IsNotEmpty()
  required: boolean;

  // Optional list of substitute ingredient names.
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
 * Describes a single cooking instruction step within a recipe payload.
 */
export class InstructionDto {
  // Step number / order within the instruction sequence.
  @ApiProperty({ description: 'Step number in the instructions' })
  @IsNotEmpty()
  @IsNumber()
  step: number;

  // Human-readable description of the step.
  @ApiProperty({ description: 'Description of the step' })
  @IsNotEmpty()
  @IsString()
  description: string;

  // Optional timer duration for the step.
  @ApiProperty({ description: 'Optional timer for the step', required: false })
  @IsOptional()
  @IsNumber()
  timer?: number;
}

/**
 * Request contract for creating a recipe.
 *
 * Validates the full recipe payload, including the nested ingredient list and
 * instruction steps, before it reaches the recipe service layer.
 */
export class CreateRecipeDto {
  // Recipe title (required, non-empty).
  @ApiProperty({ description: 'Title of the recipe' })
  @IsNotEmpty()
  @IsString()
  title: string;

  // Recipe description (required, non-empty).
  @ApiProperty({ description: 'Description of the recipe' })
  @IsNotEmpty()
  @IsString()
  description: string;

  // List of recipe ingredients; field name 'ingridientList' (misspelling preserved).
  @ApiProperty({
    description: 'List of ingredients with amounts, units, and substitutes',
    type: [IngridientListDto],
  })
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => IngridientListDto)
  ingridientList: IngridientListDto[];

  // Ordered cooking instructions, validated per item.
  @ApiProperty({
    description: 'Cooking instructions with steps and optional timers',
    type: [InstructionDto],
  })
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InstructionDto)
  instructions: InstructionDto[];

  // Preparation time required before cooking.
  @ApiProperty({ description: 'Preparation time in minutes' })
  @IsNotEmpty()
  @IsNumber()
  prepTime: number;

  // Active cooking time.
  @ApiProperty({ description: 'Cooking time in minutes' })
  @IsNotEmpty()
  @IsNumber()
  cookTime: number;

  // Number of servings the recipe yields.
  @ApiProperty({ description: 'Number of servings' })
  @IsNotEmpty()
  @IsNumber()
  servings: number;

  // Difficulty; @IsIn restricts values to 'easy' | 'medium' | 'hard'.
  @ApiProperty({
    description: 'Difficulty level of the recipe',
    enum: ['easy', 'medium', 'hard'],
  })
  @IsNotEmpty()
  @IsIn(['easy', 'medium', 'hard'])
  difficulty: 'easy' | 'medium' | 'hard';

  // Tags associated with the recipe.
  @ApiProperty({
    description: 'Tags associated with the recipe',
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags: string[];

  // Optional image URL; validated by @IsUrl.
  @ApiProperty({ description: 'Image URL of the recipe', required: false })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

  // Optional match score; @Min(0) lower bound; documented range 0-1.
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
