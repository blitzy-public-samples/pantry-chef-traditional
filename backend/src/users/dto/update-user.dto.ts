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

export class UpdateUserDto extends PartialType(CreateUserDto) {
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsOptional()
  @IsEmail()
  email?: string | null;

  @ApiProperty()
  @IsOptional()
  @MinLength(6)
  password?: string;

  @ApiProperty({ type: PreferencesDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto;

  @ApiProperty({ example: ['flour', 'sugar'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  pantry?: string[];

  @ApiProperty({ example: ['recipeId1', 'recipeId2'] })
  @IsOptional()
  @IsArray()
  favoriteRecipes?: string[];

  @ApiProperty({ example: ['Pancake recipe', 'Quick pasta'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  recentSearches?: string[];
}
