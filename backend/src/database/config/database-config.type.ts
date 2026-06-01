/**
 * Typed shape of the database configuration namespace consumed via
 * configService.getOrThrow('database', { infer: true }) and via
 * MongooseConfigService.createMongooseOptions()
 * (backend/src/database/mongoose-config.service.ts:L36-L43).
 *
 * `isDocumentDatabase` and `maxConnections` are required; all other fields
 * are optional and may be undefined when DATABASE_URL is supplied as the
 * single connection-string source (see backend/src/database/config/database.config.ts:L35-L65
 * for the @ValidateIf rules that enforce this either-URL-or-granular choice).
 *
 * Source: registered by registerAs('database', ...) in database.config.ts.
 */
export type DatabaseConfig = {
  isDocumentDatabase: boolean;
  url?: string;
  type?: string;
  host?: string;
  port?: number;
  password?: string;
  name?: string;
  username?: string;
  synchronize?: boolean;
  maxConnections: number;
  sslEnabled?: boolean;
  rejectUnauthorized?: boolean;
  ca?: string;
  key?: string;
  cert?: string;
};
