import { ApiProperty } from '@nestjs/swagger';
import { PartialType } from '@nestjs/mapped-types';
import {
  IsEmail,
  IsOptional,
  MinLength,
  IsArray,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { CreateUserDto, PreferencesDto } from './create-user.dto';
import { lowerCaseTransformer } from 'src/utils/transformers/lower-case.transformer';

/**
 * Request body for `PATCH /api/users`, which updates the currently authenticated user.
 *
 * Extends `PartialType(CreateUserDto)`, so every inherited create-user field becomes
 * optional. The fields below are re-declared explicitly as optional and reuse
 * `PreferencesDto` for the nested dietary-preferences contract. Clients send only the
 * fields they wish to change; malformed values are still rejected by the validators.
 */
export class UpdateUserDto extends PartialType(CreateUserDto) {
  // Optional email; lowercased & trimmed via lowerCaseTransformer when a value is sent.
  // Source: backend/src/utils/transformers/lower-case.transformer.ts:L4-L6
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsOptional()
  @IsEmail()
  email?: string | null;

  // Optional new password; minimum length 6 when provided (@MinLength(6)).
  @ApiProperty()
  @IsOptional()
  @MinLength(6)
  password?: string;

  // Optional nested dietary preferences (PreferencesDto); validated recursively.
  @ApiProperty({ type: PreferencesDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto;

  // Optional pantry item names; array of strings (each validated as string).
  @ApiProperty({ example: ['flour', 'sugar'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  pantry?: string[];

  // Optional favorite recipe ids; validated as an array (no per-item string check).
  @ApiProperty({ example: ['recipeId1', 'recipeId2'] })
  @IsOptional()
  @IsArray()
  favoriteRecipes?: string[];

  // Optional recent search terms; array of strings (each validated as string).
  @ApiProperty({ example: ['Pancake recipe', 'Quick pasta'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  recentSearches?: string[];
}
