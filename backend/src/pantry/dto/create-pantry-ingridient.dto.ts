import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumber,
  IsDateString,
} from 'class-validator';
import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Request body for creating a pantry ingredient owned by the authenticated user.
 */
export class CreatePantryIngridientDto {
  // Referenced Ingridient catalog entry; required (spelling 'ingridient'/'Ingridient' preserved).
  @ApiProperty({ description: 'Ingredient details' })
  @IsNotEmpty()
  ingridient: Ingridient;

  // Numeric amount of the ingredient; required.
  @ApiProperty({ description: 'Quantity of the ingredient' })
  @IsNotEmpty()
  @IsNumber()
  quantity: number;

  // Unit string (e.g., g, ml); required.
  @ApiProperty({ description: 'Unit of the ingredient' })
  @IsNotEmpty()
  @IsString()
  unit: string;

  // Optional ISO date string; validated via @IsDateString when present.
  @ApiProperty({
    description: 'Expiration date of the ingredient',
    required: false,
  })
  @IsOptional()
  @IsDateString()
  expirationDate?: Date;

  // Storage location; enum: fridge | freezer | pantry. Required.
  @ApiProperty({
    description: 'Location of the ingredient in storage',
    enum: ['fridge', 'freezer', 'pantry'],
  })
  @IsNotEmpty()
  @IsString()
  location: 'fridge' | 'freezer' | 'pantry';
}
