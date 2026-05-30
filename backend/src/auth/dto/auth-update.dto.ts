import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, MinLength } from 'class-validator';

/**
 * Validation contract for PATCH /api/v1/auth/me.
 *
 * All fields are optional (`@IsOptional()`); only the supplied subset is
 * applied. Fields:
 * - `firstName` / `lastName`: profile metadata updates.
 * - `password`: new password (enforced as `@MinLength(6)`).
 * - `oldPassword`: REQUIRED when `password` is being changed; the
 *   AuthService.update method validates the supplied old password via
 *   `bcrypt.compare` and raises `UnprocessableEntityException` (HTTP 422)
 *   on mismatch.
 *
 * Side effect (per AuthService.update): when the password is successfully
 * changed, ALL OTHER sessions for the user are soft-deleted; only the
 * caller's current session remains valid.
 */
export class AuthUpdateDto {
  @ApiProperty({ example: 'John' })
  @IsOptional()
  @IsNotEmpty({ message: 'mustBeNotEmpty' })
  firstName?: string;

  @ApiProperty({ example: 'Doe' })
  @IsOptional()
  @IsNotEmpty({ message: 'mustBeNotEmpty' })
  lastName?: string;

  @ApiProperty()
  @IsOptional()
  @IsNotEmpty()
  @MinLength(6)
  password?: string;

  @ApiProperty()
  @IsOptional()
  @IsNotEmpty({ message: 'mustBeNotEmpty' })
  oldPassword?: string;
}
