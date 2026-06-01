import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty } from 'class-validator';
import { Transform } from 'class-transformer';
import { lowerCaseTransformer } from '../../utils/transformers/lower-case.transformer';

/**
 * Request body for `POST /api/auth/email/login` — email + password credentials.
 */
export class AuthEmailLoginDto {
  // Login email; lower-cased via transformer; must be a valid, non-empty email
  @ApiProperty({ example: 'test1@example.com' })
  @Transform(lowerCaseTransformer)
  @IsEmail()
  @IsNotEmpty()
  email: string;

  // Plaintext password; must not be empty
  @ApiProperty()
  @IsNotEmpty()
  password: string;
}
