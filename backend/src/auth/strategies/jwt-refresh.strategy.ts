import { ExtractJwt, Strategy } from 'passport-jwt';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { JwtRefreshPayloadType } from './types/jwt-refresh-payload.type';
import { OrNeverType } from '../../utils/types/or-never.type';
import { AllConfigType } from 'src/config/config.type';

/**
 * Passport strategy `jwt-refresh` for the POST /api/v1/auth/refresh endpoint.
 *
 * Uses a separate secret (`auth.refreshSecret`, env: AUTH_REFRESH_SECRET)
 * and longer TTL (default 3650d) than the access-token strategy. Applied
 * exclusively via `AuthGuard('jwt-refresh')` on the refresh route in
 * AuthController. Note that this strategy authenticates the *refresh*
 * token, NOT the access token; therefore clients must send the refresh
 * token (not the access token) in the Authorization header when calling
 * POST /api/v1/auth/refresh.
 *
 * See ../README.md § Data Flows for the full login → refresh sequence
 * and ../../../../PRODUCTION_READINESS.md § Secrets Management for the
 * production hardening gap regarding the 3650d default TTL.
 */
@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(
  Strategy,
  'jwt-refresh',
) {
  /**
   * Configures the Passport JWT strategy with the refresh-token secret.
   *
   * @param configService Typed ConfigService used to read `auth.refreshSecret`
   *   (AUTH_REFRESH_SECRET). The non-null assertion (`!`) relies on the
   *   EnvironmentVariablesValidator guarantee in auth.config.ts.
   */
  constructor(configService: ConfigService<AllConfigType>) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get('auth').refreshSecret,
    });
  }

  /**
   * Passport strategy validation hook for refresh tokens.
   *
   * @param payload Decoded JWT refresh payload conforming to
   *   JwtRefreshPayloadType (contains sessionId, iat, exp).
   * @returns The payload itself; Passport assigns it to `request.user` so
   *   that AuthController.refresh can call AuthService.refreshToken with it.
   * @throws UnauthorizedException When `payload.sessionId` is missing,
   *   ensuring refresh tokens cannot be replayed without a valid session
   *   identifier.
   */
  public validate(
    payload: JwtRefreshPayloadType,
  ): OrNeverType<JwtRefreshPayloadType> {
    if (!payload.sessionId) {
      throw new UnauthorizedException();
    }

    return payload;
  }
}
