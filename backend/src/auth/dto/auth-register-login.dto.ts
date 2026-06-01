import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';
import { lowerCaseTransformer } from '../../utils/transformers/lower-case.transformer';

/**
 * Request body for `POST /api/auth/email/register` — new-account email + password.
 */
export class AuthRegisterLoginDto {
  // Registration email; lower-cased; must be a valid email
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsEmail()
  email: string;

  // New password; minimum length 6
  @ApiProperty()
  @MinLength(6)
  password: string;
}
