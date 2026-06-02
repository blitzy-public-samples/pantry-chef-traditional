import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty } from 'class-validator';

/**
 * Request body for a password reset using a hash token. (Defined for completeness; not wired to a
 * route in AuthController.)
 */
export class AuthResetPasswordDto {
  // New password; must not be empty
  @ApiProperty()
  @IsNotEmpty()
  password: string;

  // Password-reset hash token; must not be empty
  @ApiProperty()
  @IsNotEmpty()
  hash: string;
}
