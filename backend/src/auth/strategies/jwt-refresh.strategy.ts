import { ExtractJwt, Strategy } from 'passport-jwt';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { JwtRefreshPayloadType } from './types/jwt-refresh-payload.type';
import { OrNeverType } from '../../utils/types/or-never.type';
import { AllConfigType } from 'src/config/config.type';

/**
 * Passport refresh-token guard (strategy name `'jwt-refresh'`): extracts a
 * Bearer token and verifies it with the refresh-token secret
 * (`auth.refreshSecret`).
 */
@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(
  Strategy,
  'jwt-refresh',
) {
  constructor(configService: ConfigService<AllConfigType>) {
    // Verify the Bearer refresh token with auth.refreshSecret
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get('auth').refreshSecret,
    });
  }

  /**
   * Validates the decoded refresh-token payload.
   * @param payload the decoded `JwtRefreshPayloadType`
   * @returns the payload when valid
   * @throws UnauthorizedException when `payload.sessionId` is missing
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
