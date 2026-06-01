import { ExtractJwt, Strategy } from 'passport-jwt';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { OrNeverType } from '../../utils/types/or-never.type';
import { AllConfigType } from 'src/config/config.type';
import { JwtPayloadType } from './types/jwt-payload.type';

/**
 * Passport access-token guard (strategy name `'jwt'`): extracts a Bearer
 * token and verifies it with the access-token secret (`auth.secret`).
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(configService: ConfigService<AllConfigType>) {
    // Extract JWT from the Authorization: Bearer header; verify with auth.secret
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get('auth').secret,
    });
  }

  /**
   * Validates the decoded access-token payload.
   * @param payload the decoded `JwtPayloadType`
   * @returns the payload when valid
   * @throws UnauthorizedException when `payload.id` is missing
   */
  public validate(payload: JwtPayloadType): OrNeverType<JwtPayloadType> {
    if (!payload.id) {
      throw new UnauthorizedException();
    }

    return payload;
  }
}
