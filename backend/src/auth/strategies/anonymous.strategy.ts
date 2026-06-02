import { Strategy } from 'passport-anonymous';
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';

/**
 * Passport anonymous pass-through strategy (`passport-anonymous`): allows
 * optional/unauthenticated access without rejecting the request.
 */
@Injectable()
export class AnonymousStrategy extends PassportStrategy(Strategy) {
  constructor() {
    // No options: passport-anonymous performs no credential checks
    super();
  }

  /**
   * Returns the raw request unchanged so unauthenticated callers pass through.
   * @param payload unused
   * @param request the incoming request
   * @returns the request object
   */
  public validate(payload: unknown, request: unknown): unknown {
    return request;
  }
}
