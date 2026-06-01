import { PartialType } from '@nestjs/swagger';
import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsNumber, IsDateString } from 'class-validator';
import { CreatePantryIngridientDto } from './create-pantry-ingridient.dto';
import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Partial update payload for a pantry ingredient; all fields optional.
 *
 * Extends PartialType(CreatePantryIngridientDto): every inherited create field
 * becomes optional, so clients may submit only the fields they change.
 */
export class UpdatePantryIngridientDto extends PartialType(
  CreatePantryIngridientDto,
) {
  // Optional referenced Ingridient catalog entry to update (spelling preserved).
  @ApiProperty({ description: 'Ingredient details', required: false })
  @IsOptional()
  ingridient?: Ingridient;

  // Optional numeric amount of the ingredient to update.
  @ApiProperty({ description: 'Quantity of the ingredient', required: false })
  @IsOptional()
  @IsNumber()
  quantity?: number;

  // Optional unit string (e.g., g, ml) to update.
  @ApiProperty({ description: 'Unit of the ingredient', required: false })
  @IsOptional()
  @IsString()
  unit?: string;

  // Optional ISO date string; validated via @IsDateString when present.
  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  @IsDateString()
  expirationDate?: Date;

  // Optional storage location; enum: fridge | freezer | pantry.
  @ApiProperty({
    description: 'Location of the ingredient in storage',
    enum: ['fridge', 'freezer', 'pantry'],
    required: false,
  })
  @IsOptional()
  @IsString()
  location?: 'fridge' | 'freezer' | 'pantry';
}
