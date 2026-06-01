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

/**
 * Nested dietary-preferences input contract embedded in both {@link CreateUserDto} and the
 * derived `UpdateUserDto` (`PartialType(CreateUserDto)`). Captures dietary tags, allergies,
 * disliked ingredients, and a preferred cooking time. All fields are optional.
 */
export class PreferencesDto {
  // Optional dietary tags, e.g. ['vegetarian', 'vegan']; array of strings.
  @ApiProperty({ example: ['vegetarian', 'vegan'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  dietary?: string[];

  // Optional allergy tags, e.g. ['peanuts', 'shellfish']; array of strings.
  @ApiProperty({ example: ['peanuts', 'shellfish'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  allergies?: string[];

  // Optional disliked ingredients, e.g. ['onion', 'garlic']; array of strings.
  @ApiProperty({ example: ['onion', 'garlic'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  dislikedIngredients?: string[];

  // Optional preferred cooking time in minutes (number), e.g. 30.
  @ApiProperty({ example: 30 })
  @IsOptional()
  @IsNumber()
  cookingTime?: number;
}

/**
 * Request body for `POST /api/users` (create a user). `email` is required and normalized to
 * lowercase; `password` enforces a minimum length of 6. The `preferences`, `pantry`,
 * `favoriteRecipes`, and `recentSearches` fields are optional structured inputs. Acts as the
 * base DTO that `UpdateUserDto` extends via `PartialType(CreateUserDto)`.
 */
export class CreateUserDto {
  // Required email (@IsNotEmpty); lowercased and trimmed via lowerCaseTransformer.
  // Source: backend/src/utils/transformers/lower-case.transformer.ts:L4-L6
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsNotEmpty()
  @IsEmail()
  email: string | null;

  // Optional password; minimum length 6 (@MinLength(6)).
  @ApiProperty()
  @MinLength(6)
  password?: string;

  // Optional nested dietary preferences (PreferencesDto); validated recursively.
  @ApiProperty({ type: PreferencesDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto;

  // Optional pantry item names; array of strings (each validated as string).
  @ApiProperty({ example: ['salt', 'pepper'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  pantry?: string[];

  // Optional favorite recipe ids; validated as an array (no per-item string check).
  @ApiProperty({ example: ['recipeId1', 'recipeId2'], type: [String] })
  @IsOptional()
  @IsArray()
  favoriteRecipes?: string[];

  // Optional recent search terms; array of strings (each validated as string).
  @ApiProperty({ example: ['pasta', 'pizza'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  recentSearches?: string[];
}
