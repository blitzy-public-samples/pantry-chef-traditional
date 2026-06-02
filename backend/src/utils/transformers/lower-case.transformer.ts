import { TransformFnParams } from 'class-transformer/types/interfaces';
import { MaybeType } from '../types/maybe.type';

/**
 * Reusable `class-transformer` transform callback that normalizes a string
 * property by lower-casing and trimming it, while preserving nullish input via
 * optional chaining (`params.value?.`).
 *
 * Typically applied to email fields via `@Transform(lowerCaseTransformer)`.
 *
 * @param params - the `class-transformer` `TransformFnParams`; the field value
 *   is read from `params.value`.
 * @returns a `MaybeType<string>` (`string | undefined`): the lower-cased,
 *   trimmed value, or `undefined` when `params.value` is nullish.
 *   Source: backend/src/utils/types/maybe.type.ts:L2
 */
export const lowerCaseTransformer = (
  params: TransformFnParams,
): MaybeType<string> => params.value?.toLowerCase().trim();
