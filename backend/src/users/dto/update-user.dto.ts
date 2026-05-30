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
 * Validation contract for `PATCH /api/users` and `PATCH /api/auth/me`.
 *
 * Extends `PartialType(CreateUserDto)` so every inherited field becomes optional. The
 * redeclared fields exist primarily to attach `@ApiProperty()` examples that Swagger
 * surfaces at `/docs`.
 *
 * Asymmetric password handling — unlike `CreateUserDto`, the `password` field here is
 * NOT re-hashed by `UsersService.update` (see `../users.service.ts` lines 66-91; the
 * method clones the payload and forwards it verbatim to the repository without any
 * `bcrypt` call). `AuthService.update` (the consumer of this DTO from
 * `PATCH /api/auth/me`, see `../../auth/auth.service.ts` lines 188-213) verifies
 * the OLD password via `bcrypt.compare` but likewise does not re-hash a new password
 * before forwarding to `UsersService.update`. This limitation is documented in
 * `../README.md` § Known Limitations.
 */
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
