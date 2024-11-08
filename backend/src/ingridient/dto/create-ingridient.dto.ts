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

export class CreateIngridientDto {
  @ApiProperty({ description: 'Name of the ingredient' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ description: 'Category of the ingredient' })
  @IsNotEmpty()
  category: Reference;

  @ApiProperty({ description: 'Quantity of the ingredient', required: false })
  @IsOptional()
  @IsNumber()
  quantity?: number;

  @ApiProperty({ description: 'Unit of the ingredient', required: false })
  @IsOptional()
  unit?: Reference;

  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  @IsDateString()
  expirationDate?: Date;

  @ApiProperty({ description: 'Image URL of the ingredient', required: false })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

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
