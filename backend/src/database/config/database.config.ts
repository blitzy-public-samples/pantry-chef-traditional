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
 * Validator for database environment variables.
 *
 * Class-validator decorators enforce: DATABASE_URL is optional but, when
 * absent, DATABASE_TYPE / DATABASE_HOST / DATABASE_NAME / DATABASE_USERNAME
 * become required (via @ValidateIf((envValues) => !envValues.DATABASE_URL)).
 * DATABASE_PORT, DATABASE_PASSWORD, DATABASE_SYNCHRONIZE,
 * DATABASE_MAX_CONNECTIONS, DATABASE_SSL_ENABLED,
 * DATABASE_REJECT_UNAUTHORIZED, DATABASE_CA, DATABASE_KEY, DATABASE_CERT
 * are always optional (validated only when present).
 *
 * Consumed by validateConfig(process.env, EnvironmentVariablesValidator)
 * inside the default-exported registerAs factory below; that helper
 * (backend/src/utils/validate-config.ts:L9-L18) runs plainToClass with
 * enableImplicitConversion then validateSync and throws an Error at boot
 * on the first violation. The class is intentionally not exported because
 * it is an implementation detail of the factory below.
 *
 * Source: backend/src/database/config/database.config.ts:L14-L74
 */
class EnvironmentVariablesValidator {
  @ValidateIf((envValues) => envValues.DATABASE_URL)
  @IsString()
  DATABASE_URL: string;

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
 * Database configuration factory registered under the `database` namespace
 * of AllConfigType (backend/src/config/config.type.ts:L9).
 *
 * Reads DATABASE_TYPE, DATABASE_HOST, DATABASE_PORT, DATABASE_USERNAME,
 * DATABASE_PASSWORD, DATABASE_NAME, DATABASE_URL, DATABASE_SYNCHRONIZE,
 * DATABASE_MAX_CONNECTIONS, DATABASE_SSL_ENABLED, DATABASE_REJECT_UNAUTHORIZED,
 * DATABASE_CA, DATABASE_KEY, DATABASE_CERT from process.env. The validator
 * recognizes all fourteen of those names, but backend/env_example (L6-L11)
 * ships only the six commonly-set ones: DATABASE_TYPE, DATABASE_PORT,
 * DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_URL.
 *
 * Computes isDocumentDatabase = ['mongodb'].includes(DATABASE_TYPE ?? '').
 * Falls back to port 5432 when DATABASE_PORT is unset — PostgreSQL default
 * carried over from the NestJS template; backend/env_example:L7 sets 27017
 * explicitly so the fallback rarely fires in practice. Falls back to
 * maxConnections = 100 when DATABASE_MAX_CONNECTIONS is unset.
 *
 * Loaded into ConfigModule at backend/src/app.module.ts:L20-L24 (load array
 * at L22) and again at backend/src/database/seeds/seed.module.ts:L18-L22
 * for the standalone seed runner. Consumed by MongooseConfigService at
 * backend/src/database/mongoose-config.service.ts:L13-L20 via
 * `this.configService.get('database')`.
 *
 * @returns DatabaseConfig — the typed configuration object.
 * @throws Error — when validateConfig finds class-validator violations.
 */
export default registerAs<DatabaseConfig>('database', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    isDocumentDatabase: ['mongodb'].includes(process.env.DATABASE_TYPE ?? ''),
    url: process.env.DATABASE_URL,
    type: process.env.DATABASE_TYPE,
    host: process.env.DATABASE_HOST,
    port: process.env.DATABASE_PORT
      ? parseInt(process.env.DATABASE_PORT, 10)
      : 5432,
    password: process.env.DATABASE_PASSWORD,
    name: process.env.DATABASE_NAME,
    username: process.env.DATABASE_USERNAME,
    synchronize: process.env.DATABASE_SYNCHRONIZE === 'true',
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
