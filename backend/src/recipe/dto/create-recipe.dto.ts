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
