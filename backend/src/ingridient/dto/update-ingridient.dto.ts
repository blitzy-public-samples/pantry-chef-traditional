import { PartialType } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { IsOptional } from 'class-validator';
import { lowerCaseTransformer } from 'src/utils/transformers/lower-case.transformer';
import { CreateIngridientDto } from './create-ingridient.dto';
import { Reference } from 'src/common/types';

/**
 * Request body DTO for updating an ingredient.
 *
 * Extends PartialType(CreateIngridientDto) so every create field becomes
 * optional, and adds an explicit required id. The name and category values
 * are normalized to lower case before validation.
 */
export class UpdateIngridientDto extends PartialType(CreateIngridientDto) {
  // Required identifier of the ingredient to update.
  @ApiProperty({ description: 'Id of the ingredient', required: true })
  id: string;

  // Optional name; lower-cased + trimmed via @Transform(lowerCaseTransformer).
  @ApiProperty({ description: 'Name of the ingredient', required: false })
  @IsOptional()
  @Transform(lowerCaseTransformer)
  name?: string;

  // Optional category reference; lower-cased via @Transform(lowerCaseTransformer).
  @ApiProperty({ description: 'Category of the ingredient', required: false })
  @IsOptional()
  @Transform(lowerCaseTransformer)
  category?: Reference;

  // Optional numeric quantity of the ingredient.
  @ApiProperty({ description: 'Quantity of the ingredient', required: false })
  @IsOptional()
  quantity?: number;

  // Optional unit-of-measure reference ({ id, name }).
  @ApiProperty({ description: 'Unit of the ingredient', required: false })
  @IsOptional()
  unit?: Reference;

  // Optional expiration date for the ingredient.
  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  expirationDate?: Date;

  // Optional image URL for the ingredient.
  @ApiProperty({ description: 'Image URL of the ingredient', required: false })
  @IsOptional()
  imageUrl?: string;

  // Optional confidence score (0-1) for the ingredient.
  @ApiProperty({
    description: 'Confidence level of the ingredient',
    required: false,
  })
  @IsOptional()
  confidence?: number;
}
