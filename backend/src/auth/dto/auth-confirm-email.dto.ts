import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty } from 'class-validator';

/**
 * Request body carrying an email-confirmation hash token. (Defined for completeness; not wired to a
 * route in AuthController.)
 */
export class AuthConfirmEmailDto {
  // Email confirmation hash token; must not be empty
  @ApiProperty()
  @IsNotEmpty()
  hash: string;
}
