import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';
import { lowerCaseTransformer } from '../../utils/transformers/lower-case.transformer';

/**
 * Validation contract for POST /api/v1/auth/email/register.
 *
 * Consumed by AuthController.register → AuthService.register. The
 * `email` field is normalized to lowercase and validated via `@IsEmail()`.
 * The `password` field is enforced as a minimum of 6 characters via
 * `@MinLength(6)`. No other strength rules (mixed case, digits, symbols)
 * are enforced at this layer; consider tightening before production.
 *
 * Returns `Omit<LoginResponseType, 'user'>` on success;
 * raises `UnprocessableEntityException` (HTTP 422) when the email is
 * already registered.
 */
export class AuthRegisterLoginDto {
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsEmail()
  email: string;

  @ApiProperty()
  @MinLength(6)
  password: string;
}
