// NOTE: 'PantryIngridient' / 'pantry-ingridient' spellings preserved verbatim. Do not rename.
import { PartialType } from '@nestjs/swagger';
import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsNumber, IsDateString } from 'class-validator';
import { CreatePantryIngridientDto } from './create-pantry-ingridient.dto';
import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Validation contract for PATCH /api/pantry/:id — Partially update a
 * pantry item (spelling preserved verbatim).
 *
 * Extends PartialType(CreatePantryIngridientDto) and additionally declares
 * every field as optional with explicit @IsOptional + type validators so
 * Swagger documents the schema correctly. Field semantics match
 * CreatePantryIngridientDto; see ../README.md § Known Limitations for the
 * `location` enum validation gap that affects both DTOs.
 */
export class UpdatePantryIngridientDto extends PartialType(
  CreatePantryIngridientDto,
) {
  @ApiProperty({ description: 'Ingredient details', required: false })
  @IsOptional()
  ingridient?: Ingridient;

  @ApiProperty({ description: 'Quantity of the ingredient', required: false })
  @IsOptional()
  @IsNumber()
  quantity?: number;

  @ApiProperty({ description: 'Unit of the ingredient', required: false })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  @IsDateString()
  expirationDate?: Date;

  @ApiProperty({
    description: 'Location of the ingredient in storage',
    enum: ['fridge', 'freezer', 'pantry'],
    required: false,
  })
  @IsOptional()
  @IsString()
  location?: 'fridge' | 'freezer' | 'pantry';
}
