import { plainToClass } from 'class-transformer';
import { validateSync } from 'class-validator';
import { ClassConstructor } from 'class-transformer/types/interfaces';

/**
 * Validates a plain configuration record against a decorated env-variables class.
 *
 * Converts the raw `config` record into an instance of `envVariablesClass` via
 * `plainToClass` with `enableImplicitConversion: true`, so string environment values are
 * coerced to their declared types. It then runs synchronous `class-validator` checks via
 * `validateSync` with `skipMissingProperties: false`, so missing required variables fail
 * validation. This helper is synchronous and never returns a Promise.
 *
 * Source: backend/src/utils/validate-config.ts:L9-L11 (implicit type conversion).
 * Source: backend/src/utils/validate-config.ts:L16-L18 (throws on validation errors).
 *
 * @typeParam T - The env-variables class type (`extends object`).
 * @param config - The raw config object (`Record<string, unknown>`, e.g. `process.env`).
 * @param envVariablesClass - The `ClassConstructor<T>` decorated with `class-validator` rules.
 * @returns The validated, type-coerced instance of `T`.
 * @throws {Error} When validation produces one or more errors; message is `errors.toString()`.
 */
function validateConfig<T extends object>(
  config: Record<string, unknown>,
  envVariablesClass: ClassConstructor<T>,
) {
  // Instantiate the class from the plain record; coerce primitive types implicitly.
  const validatedConfig = plainToClass(envVariablesClass, config, {
    enableImplicitConversion: true,
  });
  // Validate synchronously; do not skip missing properties (required vars must exist).
  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  // Aggregate all validation errors into a single thrown Error.
  if (errors.length > 0) {
    throw new Error(errors.toString());
  }
  return validatedConfig;
}

export default validateConfig;
