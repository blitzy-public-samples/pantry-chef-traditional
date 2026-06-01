import { AppConfig } from './app-config.type';
import { AuthConfig } from '../auth/config/auth-config.type';
import { DatabaseConfig } from '../database/config/database-config.type';
// import { MailConfig } from '../mail/config/mail-config.type';

/**
 * Aggregate type unifying every typed configuration namespace exposed
 * through `@nestjs/config`'s `ConfigService<AllConfigType>`.
 *
 * Active members:
 * - `app`: `AppConfig` — produced by `./app.config.ts` (see this folder's
 *   README). Fields: `nodeEnv`, `name`, `workingDirectory`, `port`,
 *   `apiPrefix`.
 * - `auth`: `AuthConfig` — produced by `../auth/config/auth.config.ts`.
 *   Fields: `secret`, `expires`, `refreshSecret`, `refreshExpires` (all
 *   optional; sourced from `AUTH_JWT_SECRET`, `AUTH_JWT_TOKEN_EXPIRES_IN`,
 *   `AUTH_REFRESH_SECRET`, `AUTH_REFRESH_TOKEN_EXPIRES_IN`).
 * - `database`: `DatabaseConfig` — produced by
 *   `../database/config/database.config.ts`. Drives `MongooseConfigService`
 *   in `../database/mongoose-config.service.ts`.
 *
 * Consumed by every feature module via
 * `configService.getOrThrow('<namespace>.<key>', { infer: true })`
 * — e.g., `backend/src/main.ts:L14-L19` reads `app.apiPrefix` and
 * `backend/src/main.ts:L33` reads `app.port`.
 */
export type AllConfigType = {
  app: AppConfig;
  auth: AuthConfig;
  database: DatabaseConfig;
  // NOTE: The `mail: MailConfig;` line below is intentionally commented out; it pairs with
  // NOTE: the commented `// MailModule,` import in `backend/src/auth/auth.module.ts`. The mail
  // NOTE: feature (delivering AuthForgotPasswordDto / AuthResetPasswordDto reset emails) is NOT
  // NOTE: implemented; both lines are preserved verbatim as a follow-up marker. See
  // NOTE: backend/src/auth/README.md and backend/src/config/README.md § Known Limitations.
  // mail: MailConfig;
};
