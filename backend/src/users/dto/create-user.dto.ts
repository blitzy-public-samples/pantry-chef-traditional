import { Transform, Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  MinLength,
  IsOptional,
  IsArray,
  IsString,
  IsNumber,
  ValidateNested,
} from 'class-validator';
import { lowerCaseTransformer } from 'src/utils/transformers/lower-case.transformer';

export class PreferencesDto {
  @ApiProperty({ example: ['vegetarian', 'vegan'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  dietary?: string[];

  @ApiProperty({ example: ['peanuts', 'shellfish'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  allergies?: string[];

  @ApiProperty({ example: ['onion', 'garlic'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  dislikedIngredients?: string[];

  @ApiProperty({ example: 30 })
  @IsOptional()
  @IsNumber()
  cookingTime?: number;
}

export class CreateUserDto {
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsNotEmpty()
  @IsEmail()
  email: string | null;

  @ApiProperty()
  @MinLength(6)
  password?: string;

  @ApiProperty({ type: PreferencesDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto;

  @ApiProperty({ example: ['salt', 'pepper'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  pantry?: string[];

  @ApiProperty({ example: ['recipeId1', 'recipeId2'], type: [String] })
  @IsOptional()
  @IsArray()
  favoriteRecipes?: string[];

  @ApiProperty({ example: ['pasta', 'pizza'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  recentSearches?: string[];
}
