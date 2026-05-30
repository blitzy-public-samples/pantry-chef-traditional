import { ApiProperty } from '@nestjs/swagger';
import { IsEmail } from 'class-validator';
import { Transform } from 'class-transformer';
import { lowerCaseTransformer } from '../../utils/transformers/lower-case.transformer';

/**
 * DTO for the forgot-password flow (initiate password reset by email).
 *
 * WARNING — this DTO is currently UNWIRED. No `POST /api/auth/forgot-password`
 * endpoint exists in AuthController; the matching `MailModule` import in
 * AuthModule is commented out (see auth.module.ts). The forgot-password
 * flow is therefore non-functional in the current codebase.
 *
 * Production gap callouts:
 * - See ../README.md § Known Limitations and Implementation Gaps
 * - See ../../../../PRODUCTION_READINESS.md § Security Hardening (Wire password
 *   reset endpoints)
 *
 * To wire up: implement `POST /api/auth/forgot-password` in AuthController,
 * inject MailService into AuthService, and uncomment the MailModule import
 * in auth.module.ts.
 */
// TODO(prod): Wire this DTO into AuthController via POST /api/auth/forgot-password.
export class AuthForgotPasswordDto {
  @ApiProperty()
  @Transform(lowerCaseTransformer)
  @IsEmail()
  email: string;
}
