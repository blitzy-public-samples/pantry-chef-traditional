import { ApiProperty } from '@nestjs/swagger';
import { IsEmail } from 'class-validator';
import { Transform } from 'class-transformer';
import { lowerCaseTransformer } from '../../utils/transformers/lower-case.transformer';

/**
 * Request body for a forgot-password request. (Defined for completeness; not wired to a route in
 * AuthController.)
 */
export class AuthForgotPasswordDto {
  // Account email; lower-cased; must be a valid email
  @ApiProperty()
  @Transform(lowerCaseTransformer)
  @IsEmail()
  email: string;
}
