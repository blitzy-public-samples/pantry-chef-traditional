import { ExtractJwt, Strategy } from 'passport-jwt';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { OrNeverType } from '../../utils/types/or-never.type';
import { AllConfigType } from 'src/config/config.type';
import { JwtPayloadType } from './types/jwt-payload.type';

/**
 * Passport strategy `jwt` for access-token-protected routes.
 *
 * Extracts the bearer token from the `Authorization: Bearer <token>` header
 * (via `ExtractJwt.fromAuthHeaderAsBearerToken()`) and verifies it using
 * the secret from `configService.get('auth').secret` (env: AUTH_JWT_SECRET).
 *
 * On success, populates `request.user` with the validated `JwtPayloadType`
 * (containing `id` and `sessionId`). On failure, the underlying Passport
 * pipeline raises an `UnauthorizedException` before the route handler runs.
 *
 * Registered via `AuthGuard('jwt')` on `/me` (GET, PATCH, DELETE) and
 * `/logout` (POST). See ../README.md § API Endpoint Reference.
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  /**
   * Configures the Passport JWT strategy with the access-token secret.
   *
   * @param configService Typed ConfigService used to read `auth.secret`
   *   (AUTH_JWT_SECRET). The non-null assertion (`!`) is used because
   *   the EnvironmentVariablesValidator in auth.config.ts guarantees
   *   the value is present at bootstrap.
   */
  constructor(configService: ConfigService<AllConfigType>) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get('auth').secret,
    });
  }

  /**
   * Passport strategy validation hook invoked after JWT signature
   * verification succeeds.
   *
   * @param payload Decoded JWT payload conforming to JwtPayloadType.
   * @returns The payload itself; Passport assigns it to `request.user`.
   * @throws UnauthorizedException When `payload.id` is missing, ensuring
   *   that malformed tokens — even those that pass signature verification —
   *   cannot authenticate a request.
   */
  public validate(payload: JwtPayloadType): OrNeverType<JwtPayloadType> {
    if (!payload.id) {
      throw new UnauthorizedException();
    }

    return payload;
  }
}
