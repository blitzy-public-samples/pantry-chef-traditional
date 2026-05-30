import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty } from 'class-validator';
import { Transform } from 'class-transformer';
import { lowerCaseTransformer } from '../../utils/transformers/lower-case.transformer';

/**
 * Validation contract for POST /api/v1/auth/email/login.
 *
 * Consumed by AuthController.login → AuthService.validateLogin. The
 * `email` field is normalized to lowercase by `@Transform` and validated
 * as a syntactic email via `@IsEmail()`. The `password` field is required
 * but otherwise unconstrained at the DTO layer — strength rules apply
 * only at registration (see AuthRegisterLoginDto).
 *
 * Returns `Omit<LoginResponseType, 'user'>` on success;
 * raises `UnprocessableEntityException` (HTTP 422) on credential mismatch
 * or unknown email.
 */
export class AuthEmailLoginDto {
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty()
  @IsNotEmpty()
  password: string;
}
