import { PartialType } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, ValidateNested, IsArray } from 'class-validator';
import { lowerCaseTransformer } from 'src/utils/transformers/lower-case.transformer';
import { CreateRecipeDto } from './create-recipe.dto';
import { IngridientListDto, InstructionDto } from './create-recipe.dto';

/**
 * Request contract for partial recipe updates.
 *
 * Extends `PartialType(CreateRecipeDto)`, so every CreateRecipeDto field is
 * inherited as optional. This DTO additionally declares the recipe `id` and the
 * lifecycle/timestamp fields (`createdAt`, `updatedAt`, `deletedAt`).
 */
export class UpdateRecipeDto extends PartialType(CreateRecipeDto) {
  // Identifier of the recipe to update (required).
  @ApiProperty({ description: 'Id of the recipe', required: true })
  id: string;

  // Optional new title; normalized to lowercase and trimmed via lowerCaseTransformer.
  @ApiProperty({ description: 'Title of the recipe', required: false })
  @IsOptional()
  @Transform(lowerCaseTransformer)
  title?: string;

  // Optional new recipe description.
  @ApiProperty({ description: 'Description of the recipe', required: false })
  @IsOptional()
  description?: string;

  // Optional replacement ingredient list; field name keeps the 'ingredientList' spelling.
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

  // Optional replacement cooking instructions, validated per item.
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

  // Optional new preparation time.
  @ApiProperty({ description: 'Preparation time in minutes', required: false })
  @IsOptional()
  prepTime?: number;

  // Optional new cooking time.
  @ApiProperty({ description: 'Cooking time in minutes', required: false })
  @IsOptional()
  cookTime?: number;

  // Optional new servings count.
  @ApiProperty({ description: 'Number of servings', required: false })
  @IsOptional()
  servings?: number;

  // Optional new difficulty; type union 'easy' | 'medium' | 'hard'.
  @ApiProperty({
    description: 'Difficulty level of the recipe',
    enum: ['easy', 'medium', 'hard'],
    required: false,
  })
  @IsOptional()
  difficulty?: 'easy' | 'medium' | 'hard';

  // Optional new tag list.
  @ApiProperty({
    description: 'Tags associated with the recipe',
    type: [String],
    required: false,
  })
  @IsOptional()
  tags?: string[];

  // Optional new image URL.
  @ApiProperty({ description: 'Image URL of the recipe', required: false })
  @IsOptional()
  imageUrl?: string;

  // Optional match score for recommendation engines.
  @ApiProperty({
    description: 'Match score for recommendation engines',
    required: false,
  })
  @IsOptional()
  matchScore?: number;

  // Optional creation timestamp.
  @ApiProperty({ description: 'Creation date', required: false })
  @IsOptional()
  createdAt?: Date;

  // Optional last-update timestamp.
  @ApiProperty({ description: 'Last update date', required: false })
  @IsOptional()
  updatedAt?: Date;

  // Optional soft-delete timestamp.
  @ApiProperty({ description: 'Deletion date', required: false })
  @IsOptional()
  deletedAt?: Date;
}
