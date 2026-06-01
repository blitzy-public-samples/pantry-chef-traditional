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
 * Nested DTO for the embedded `Preferences` subdocument inside `UserSchemaClass`.
 *
 * Used by `CreateUserDto.preferences` and `UpdateUserDto.preferences` via
 * `@ValidateNested()` and `@Type(() => PreferencesDto)`. Persisted as an embedded
 * subdocument with Mongoose-level defaults (`dietary: []`, `allergies: []`,
 * `dislikedIngredients: []`, `cookingTime: 0`) declared at
 * `../infrastructure/document/entities/user.schema.ts` lines 41-49.
 *
 * Consumed downstream by `RecipeService.matches` to drive the four pre-filter
 * steps of the recipe matching pipeline (`$nin` on `allergies` and
 * `dislikedIngredients`, `$all` on `dietary`, `$lte` on `cookingTime`). See
 * `../../../../ARCHITECTURE.md` § Recipe Matching Pipeline for the full algorithm.
 */
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

/**
 * Validation contract for `POST /api/users`.
 *
 * Handled by `UsersController.create` → `UsersService.create`. The `password`
 * field carries the plaintext password; `UsersService.create` hashes it via
 * `bcrypt.genSalt(10)` + `bcrypt.hash` before persistence (see
 * `../users.service.ts` lines 21-24). This DTO is therefore the only place where
 * a plaintext password enters the users service tier.
 *
 * `email` is lowercased AND trimmed by `lowerCaseTransformer` before validation
 * (the transformer body is `params.value?.toLowerCase().trim()`), then enforced
 * unique at the Mongoose schema level (`UserSchemaClass.email` declared with
 * `unique: true` at `../infrastructure/document/entities/user.schema.ts` lines
 * 30-33). `UsersService.create` additionally performs a pre-flight `findOne`
 * lookup and throws a 422 Unprocessable Entity before reaching MongoDB.
 *
 * The `preferences` field accepts a nested `PreferencesDto` for the embedded
 * subdocument; `pantry?: string[]` is declared here but is NOT propagated to the
 * persistence layer by `UsersService.create` — pantry items are owned by the
 * separate `PantryModule` (see `../../pantry/README.md`). `favoriteRecipes` and
 * `recentSearches` ARE persisted by the schema as unbounded arrays (limitation
 * documented in `../README.md` § Known Limitations).
 *
 * All decorators are evaluated by the global `ValidationPipe` registered in
 * `../../main.ts` line 21.
 */
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
