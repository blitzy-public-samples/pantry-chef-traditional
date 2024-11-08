import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumber,
  IsDateString,
} from 'class-validator';
import { Ingridient } from 'src/ingridient/domain/ingrident';

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
