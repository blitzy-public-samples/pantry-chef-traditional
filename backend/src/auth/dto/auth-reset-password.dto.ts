import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty } from 'class-validator';

/**
 * DTO for the reset-password flow (apply a new password using a reset hash).
 *
 * WARNING — this DTO is currently UNWIRED. No `POST /api/v1/auth/reset-password`
 * endpoint exists in AuthController; consequently, even if a user obtained
 * a reset hash through some out-of-band mechanism, there is no route that
 * would accept it.
 *
 * Properties:
 * - `password`: the new password (will need MinLength enforcement when wired,
 *   matching AuthRegisterLoginDto and AuthUpdateDto).
 * - `hash`: the single-use reset token issued by the (unimplemented)
 *   forgot-password flow.
 *
 * Production gap callouts:
 * - See ../README.md § Known Limitations and Implementation Gaps
 * - See ../../../PRODUCTION_READINESS.md § Security Hardening (Wire password
 *   reset endpoints)
 */
// TODO(prod): Wire this DTO into AuthController via POST /api/v1/auth/reset-password.
export class AuthResetPasswordDto {
  @ApiProperty()
  @IsNotEmpty()
  password: string;

  @ApiProperty()
  @IsNotEmpty()
  hash: string;
}
