import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumber,
  IsDateString,
  IsUrl,
  Min,
  Max,
} from 'class-validator';
import { Reference } from 'src/common/types';

/**
 * Request body DTO for creating an ingredient.
 *
 * Defines the validated, Swagger-documented contract for the ingredient
 * creation endpoint; each property is checked by class-validator decorators
 * and surfaced through @ApiProperty.
 */
export class CreateIngridientDto {
  // Required, non-empty display name of the ingredient.
  @ApiProperty({ description: 'Name of the ingredient' })
  @IsNotEmpty()
  @IsString()
  name: string;

  // Required category reference ({ id, name }) for the ingredient.
  @ApiProperty({ description: 'Category of the ingredient' })
  @IsNotEmpty()
  category: Reference;

  // Optional numeric quantity of the ingredient.
  @ApiProperty({ description: 'Quantity of the ingredient', required: false })
  @IsOptional()
  @IsNumber()
  quantity?: number;

  // Optional unit-of-measure reference ({ id, name }).
  @ApiProperty({ description: 'Unit of the ingredient', required: false })
  @IsOptional()
  unit?: Reference;

  // Optional expiration date as an ISO 8601 date string.
  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  @IsDateString()
  expirationDate?: Date;

  // Optional image URL for the ingredient.
  @ApiProperty({ description: 'Image URL of the ingredient', required: false })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

  // Required confidence score constrained to the inclusive range 0-1.
  @ApiProperty({
    description: 'Confidence level of the ingredient',
    minimum: 0,
    maximum: 1,
  })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @Max(1)
  confidence: number;
}
