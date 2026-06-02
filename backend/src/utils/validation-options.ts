import {
  HttpException,
  HttpStatus,
  ValidationError,
  ValidationPipeOptions,
} from '@nestjs/common';

// generateErrors recursively flattens a nested class-validator ValidationError[] tree into a
// structured payload of shape { [property]: message | nestedObject }. For each error node, a leaf
// (no children) joins its constraint messages from Object.values(constraints) with ', ', while a
// node WITH children recurses via generateErrors(currentValue.children) to mirror nested DTO shape.
// This is a module-private (non-exported) helper, consumed only by the exceptionFactory below.
// Source: backend/src/utils/validation-options.ts:L8-L19
function generateErrors(errors: ValidationError[]) {
  return errors.reduce(
    (accumulator, currentValue) => ({
      ...accumulator,
      [currentValue.property]:
        (currentValue.children?.length ?? 0) > 0
          ? generateErrors(currentValue.children ?? [])
          : Object.values(currentValue.constraints ?? {}).join(', '),
    }),
    {},
  );
}

/**
 * Shared NestJS {@link ValidationPipeOptions} consumed as the application's GLOBAL ValidationPipe.
 *
 * This is the module's default export, imported by `backend/src/main.ts:L7` and registered at
 * `backend/src/main.ts:L21` via `app.useGlobalPipes(new ValidationPipe(validationOptions))`, so it
 * governs request-payload validation for every incoming HTTP request.
 *
 * Settings:
 * - `transform: true` — incoming payloads are transformed into their DTO class instances.
 * - `whitelist: true` — properties without validation decorators are stripped from the payload.
 * - `errorHttpStatusCode: HttpStatus.UNPROCESSABLE_ENTITY` — validation failures return HTTP 422.
 * - `exceptionFactory` — builds an HttpException whose body is
 *   `{ status: 422, errors: generateErrors(errors) }`.
 *
 * Source: backend/src/utils/validation-options.ts:L21-L34
 * Source: backend/src/main.ts:L7,L21
 */
const validationOptions: ValidationPipeOptions = {
  transform: true,
  whitelist: true,
  // Validation failures surface as HTTP 422 Unprocessable Entity.
  errorHttpStatusCode: HttpStatus.UNPROCESSABLE_ENTITY,
  // Shape errors into a structured { field: message } body via generateErrors.
  exceptionFactory: (errors: ValidationError[]) => {
    return new HttpException(
      {
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errors: generateErrors(errors),
      },
      HttpStatus.UNPROCESSABLE_ENTITY,
    );
  },
};

export default validationOptions;
