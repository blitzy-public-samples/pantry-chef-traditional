import { Strategy } from 'passport-anonymous';
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';

/**
 * Passport `anonymous` strategy that allows a route to proceed without
 * validating credentials.
 *
 * Registered as a provider in AuthModule but NOT currently applied to any
 * route via @UseGuards. The unauthenticated routes (POST /email/login and
 * POST /email/register) simply declare no guard rather than using this
 * strategy. Unlike `jwt` and `jwt-refresh`, this strategy validates nothing —
 * `validate()` returns the request unchanged so the Passport pipeline proceeds
 * without raising `UnauthorizedException`.
 *
 * If applied via AuthGuard('anonymous'), it would let a route accept anonymous
 * traffic without Passport's default rejection on missing credentials.
 */
@Injectable()
export class AnonymousStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super();
  }

  /**
   * Pass-through validation that accepts any incoming request.
   *
   * @param request The incoming HTTP request, returned unchanged.
   * @returns The request itself, signalling success to Passport.
   */
  public validate(payload: unknown, request: unknown): unknown {
    return request;
  }
}
