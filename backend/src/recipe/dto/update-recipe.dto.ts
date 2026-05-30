// NOTE: 'IngridientListDto' and parent 'ingridientList' field preserved verbatim. Do not rename.
import { PartialType } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, ValidateNested, IsArray } from 'class-validator';
import { lowerCaseTransformer } from 'src/utils/transformers/lower-case.transformer';
import { CreateRecipeDto } from './create-recipe.dto';
import { IngridientListDto, InstructionDto } from './create-recipe.dto';

/**
 * Validation contract for PATCH /api/recipe/:id.
 *
 * Extends `PartialType(CreateRecipeDto)` so every field from CreateRecipeDto
 * is optional. Re-declares each field locally to expose a different Swagger
 * `required: false` documentation and to add a `lowerCaseTransformer` to the
 * `title` field. Also adds optional lifecycle fields (`id`, `createdAt`,
 * `updatedAt`, `deletedAt`) and an optional `matchScore` for symmetry with
 * the Recipe domain entity.
 *
 * NOTE: the property declared on this class at L31 is named `ingredientList?`
 * (correct English spelling) and does NOT shadow the parent's `ingridientList`
 * field name (preserved verbatim) — this is a known inconsistency in source
 * that is preserved per the minimal-change clause.
 */
export class UpdateRecipeDto extends PartialType(CreateRecipeDto) {
  @ApiProperty({ description: 'Id of the recipe', required: true })
  id: string;

  @ApiProperty({ description: 'Title of the recipe', required: false })
  @IsOptional()
  @Transform(lowerCaseTransformer)
  title?: string;

  @ApiProperty({ description: 'Description of the recipe', required: false })
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'List of ingredients with amounts, units, and substitutes',
    type: [IngridientListDto],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => IngridientListDto)
  ingredientList?: IngridientListDto[];

  @ApiProperty({
    description: 'Cooking instructions with steps and optional timers',
    type: [InstructionDto],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InstructionDto)
  instructions?: InstructionDto[];

  @ApiProperty({ description: 'Preparation time in minutes', required: false })
  @IsOptional()
  prepTime?: number;

  @ApiProperty({ description: 'Cooking time in minutes', required: false })
  @IsOptional()
  cookTime?: number;

  @ApiProperty({ description: 'Number of servings', required: false })
  @IsOptional()
  servings?: number;

  @ApiProperty({
    description: 'Difficulty level of the recipe',
    enum: ['easy', 'medium', 'hard'],
    required: false,
  })
  @IsOptional()
  difficulty?: 'easy' | 'medium' | 'hard';

  @ApiProperty({
    description: 'Tags associated with the recipe',
    type: [String],
    required: false,
  })
  @IsOptional()
  tags?: string[];

  @ApiProperty({ description: 'Image URL of the recipe', required: false })
  @IsOptional()
  imageUrl?: string;

  @ApiProperty({
    description: 'Match score for recommendation engines',
    required: false,
  })
  @IsOptional()
  matchScore?: number;

  @ApiProperty({ description: 'Creation date', required: false })
  @IsOptional()
  createdAt?: Date;

  @ApiProperty({ description: 'Last update date', required: false })
  @IsOptional()
  updatedAt?: Date;

  @ApiProperty({ description: 'Deletion date', required: false })
  @IsOptional()
  deletedAt?: Date;
}
