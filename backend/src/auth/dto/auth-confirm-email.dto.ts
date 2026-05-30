import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty } from 'class-validator';

/**
 * Validation contract for the email-confirmation flow.
 *
 * Carries the confirmation `hash` token issued during registration.
 * No controller endpoint currently consumes this DTO directly; it is
 * defined for forward compatibility with an email-confirmation workflow.
 */
export class AuthConfirmEmailDto {
  @ApiProperty()
  @IsNotEmpty()
  hash: string;
}
