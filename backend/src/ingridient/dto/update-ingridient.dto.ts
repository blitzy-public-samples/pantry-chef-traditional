import { PartialType } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { IsOptional } from 'class-validator';
import { lowerCaseTransformer } from 'src/utils/transformers/lower-case.transformer';
import { CreateIngridientDto } from './create-ingridient.dto';
import { Reference } from 'src/common/types';

export class UpdateIngridientDto extends PartialType(CreateIngridientDto) {
  @ApiProperty({ description: 'Id of the ingredient', required: true })
  id: string;

  @ApiProperty({ description: 'Name of the ingredient', required: false })
  @IsOptional()
  @Transform(lowerCaseTransformer)
  name?: string;

  @ApiProperty({ description: 'Category of the ingredient', required: false })
  @IsOptional()
  @Transform(lowerCaseTransformer)
  category?: Reference;

  @ApiProperty({ description: 'Quantity of the ingredient', required: false })
  @IsOptional()
  quantity?: number;

  @ApiProperty({ description: 'Unit of the ingredient', required: false })
  @IsOptional()
  unit?: Reference;

  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  expirationDate?: Date;

  @ApiProperty({ description: 'Image URL of the ingredient', required: false })
  @IsOptional()
  imageUrl?: string;

  @ApiProperty({
    description: 'Confidence level of the ingredient',
    required: false,
  })
  @IsOptional()
  confidence?: number;
}
