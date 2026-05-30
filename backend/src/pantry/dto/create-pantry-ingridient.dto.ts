// NOTE: 'PantryIngridient' / 'pantry-ingridient' spellings preserved verbatim. Do not rename.
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
 * Validation contract for POST /api/pantry — Create a new pantry item.
 *
 * Requires an `ingridient` reference (spelling preserved verbatim), quantity,
 * unit, and a `location` (one of 'fridge' | 'freezer' | 'pantry'). The
 * `expirationDate` is optional. `userId` is NOT in this DTO — it is injected
 * by PantryController.create from req.user.id (populated by JwtStrategy).
 *
 * NOTE: The `location` field uses @IsString() but no @IsEnum, so invalid
 * enum values are rejected by Mongoose schema validation at write time
 * rather than by ValidationPipe at the request layer. See ../README.md
 * § Known Limitations.
 */
export class CreatePantryIngridientDto {
  @ApiProperty({ description: 'Ingredient details' })
  @IsNotEmpty()
  ingridient: Ingridient;

  @ApiProperty({ description: 'Quantity of the ingredient' })
  @IsNotEmpty()
  @IsNumber()
  quantity: number;

  @ApiProperty({ description: 'Unit of the ingredient' })
  @IsNotEmpty()
  @IsString()
  unit: string;

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
  })
  @IsNotEmpty()
  @IsString()
  location: 'fridge' | 'freezer' | 'pantry';
}
