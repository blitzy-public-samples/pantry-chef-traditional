import { Strategy } from 'passport-anonymous';
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';

/**
 * Passport `anonymous` strategy enabling unauthenticated route handlers.
 *
 * Used implicitly for endpoints such as POST /api/v1/auth/email/login and
 * POST /api/v1/auth/email/register that must accept requests from
 * unauthenticated clients. Unlike `jwt` and `jwt-refresh` strategies, this
 * one does not validate any credentials — `validate()` returns the request
 * unchanged so the Passport pipeline proceeds without raising
 * `UnauthorizedException`.
 *
 * Without this strategy, routes that should accept anonymous traffic would
 * still trigger Passport's default rejection on missing credentials.
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
