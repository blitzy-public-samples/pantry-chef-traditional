import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import deepResolvePromises from './deep-resolver';

/**
 * NestJS response-serialization interceptor that taps the outgoing
 * controller-response stream and recursively resolves any nested
 * `Promise` values before the payload is serialized and returned to
 * the client.
 *
 * Delegates the recursive unwrapping to `deepResolvePromises` (imported
 * from `./deep-resolver`) by piping `next.handle()` through an RxJS
 * `map` operator, turning deferred values emitted by controllers or
 * services into plain, serializable data on the response.
 *
 * Annotated with `@Injectable()`, so the interceptor can be registered
 * globally or per-route by the consuming application. This file only
 * declares the capability; it does not register the interceptor.
 *
 * Source: backend/src/utils/deep-resolver.ts:L25
 */
@Injectable()
export class ResolvePromisesInterceptor implements NestInterceptor {
  /**
   * Intercepts the outgoing response stream and resolves nested
   * Promises before serialization.
   *
   * @param context - The NestJS `ExecutionContext` for the current
   *   request. It is part of the `NestInterceptor` contract but is not
   *   used by this implementation's body.
   * @param next - The `CallHandler` whose `handle()` returns the
   *   response `Observable` to be transformed.
   * @returns An `Observable<unknown>` that emits the response payload
   *   with all nested `Promise` values resolved.
   */
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    // Map the response stream through deepResolvePromises to unwrap
    // any nested Promise values before serialization.
    return next.handle().pipe(map((data) => deepResolvePromises(data)));
  }
}
