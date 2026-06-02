import { registerAs } from '@nestjs/config';
import { DatabaseConfig } from 'src/database/config/database-config.type';
import {
  IsOptional,
  IsInt,
  Min,
  Max,
  IsString,
  ValidateIf,
  IsBoolean,
} from 'class-validator';
import validateConfig from '../../utils/validate-config';

/**
 * Validates the database-related environment variables for the `database` config namespace.
 *
 * Enforces two mutually exclusive modes via `@ValidateIf`: either a single `DATABASE_URL`
 * connection string, or granular `DATABASE_TYPE`/`DATABASE_HOST`/`DATABASE_PORT`/
 * `DATABASE_NAME`/`DATABASE_USERNAME`/`DATABASE_PASSWORD` settings.
 */
class EnvironmentVariablesValidator {
  // Mode A: a single DATABASE_URL connection string (validated only when present).
  @ValidateIf((envValues) => envValues.DATABASE_URL)
  @IsString()
  DATABASE_URL: string;

  // Mode B: granular host/type/credential settings (validated when DATABASE_URL is absent).
  @ValidateIf((envValues) => !envValues.DATABASE_URL)
  @IsString()
  DATABASE_TYPE: string;

  @ValidateIf((envValues) => !envValues.DATABASE_URL)
  @IsString()
  DATABASE_HOST: string;

  @ValidateIf((envValues) => !envValues.DATABASE_URL)
  @IsInt()
  @Min(0)
  @Max(65535)
  @IsOptional()
  DATABASE_PORT: number;

  @ValidateIf((envValues) => !envValues.DATABASE_URL)
  @IsString()
  @IsOptional()
  DATABASE_PASSWORD: string;

  @ValidateIf((envValues) => !envValues.DATABASE_URL)
  @IsString()
  DATABASE_NAME: string;

  @ValidateIf((envValues) => !envValues.DATABASE_URL)
  @IsString()
  DATABASE_USERNAME: string;

  @IsBoolean()
  @IsOptional()
  DATABASE_SYNCHRONIZE: boolean;

  @IsInt()
  @IsOptional()
  DATABASE_MAX_CONNECTIONS: number;

  @IsBoolean()
  @IsOptional()
  DATABASE_SSL_ENABLED: boolean;

  @IsBoolean()
  @IsOptional()
  DATABASE_REJECT_UNAUTHORIZED: boolean;

  @IsString()
  @IsOptional()
  DATABASE_CA: string;

  @IsString()
  @IsOptional()
  DATABASE_KEY: string;

  @IsString()
  @IsOptional()
  DATABASE_CERT: string;
}

/**
 * Registers the `database` configuration namespace via NestJS `registerAs`.
 *
 * Validates `process.env` against {@link EnvironmentVariablesValidator} and maps the
 * environment variables into the typed configuration object.
 *
 * @returns The typed {@link DatabaseConfig} (e.g. `url`, `name`, `username`, `password`,
 * `port`, `maxConnections`, `isDocumentDatabase`) assembled from `process.env`.
 * @throws Error when `validateConfig` finds invalid environment variables.
 */
export default registerAs<DatabaseConfig>('database', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    // True only when DATABASE_TYPE is 'mongodb'; selects document-database behavior.
    isDocumentDatabase: ['mongodb'].includes(process.env.DATABASE_TYPE ?? ''),
    // Becomes the Mongoose connection `uri` downstream in MongooseConfigService.
    url: process.env.DATABASE_URL,
    type: process.env.DATABASE_TYPE,
    host: process.env.DATABASE_HOST,
    // KNOWN ISSUE: defaults to 5432 (a Postgres-style port) when DATABASE_PORT is unset,
    // even though the stack runs MongoDB.
    port: process.env.DATABASE_PORT
      ? parseInt(process.env.DATABASE_PORT, 10)
      : 5432,
    password: process.env.DATABASE_PASSWORD,
    name: process.env.DATABASE_NAME,
    username: process.env.DATABASE_USERNAME,
    synchronize: process.env.DATABASE_SYNCHRONIZE === 'true',
    // Defaults to 100 when DATABASE_MAX_CONNECTIONS is unset.
    maxConnections: process.env.DATABASE_MAX_CONNECTIONS
      ? parseInt(process.env.DATABASE_MAX_CONNECTIONS, 10)
      : 100,
    sslEnabled: process.env.DATABASE_SSL_ENABLED === 'true',
    rejectUnauthorized: process.env.DATABASE_REJECT_UNAUTHORIZED === 'true',
    ca: process.env.DATABASE_CA,
    key: process.env.DATABASE_KEY,
    cert: process.env.DATABASE_CERT,
  };
});
