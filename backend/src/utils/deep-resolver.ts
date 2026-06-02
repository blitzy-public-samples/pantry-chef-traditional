/**
 * Recursively walks an arbitrary input value and returns a structurally
 * identical value with every nested `Promise` awaited (deep promise
 * unwrapping). Used to normalize controller responses that may embed
 * unresolved Promises at any depth.
 *
 * Traversal rules, applied in order:
 * - A `Promise` is awaited and its resolved value returned.
 * - An array is resolved element-by-element via `Promise.all` (recursively).
 * - A `Date` instance is returned as-is (not treated as a plain object).
 * - A non-null plain object is rebuilt key-by-key, awaiting each value
 *   recursively.
 * - Any other value (primitive, `null`, function) is returned unchanged.
 *
 * This is the core helper used by `ResolvePromisesInterceptor` to normalize
 * controller responses before serialization.
 *
 * @param input - any value: a `Promise`, array, `Date`, plain object, or
 *   primitive. Intentionally untyped (implicit any) to accept any shape.
 * @returns a `Promise` resolving to the same structure with all nested
 *   Promises resolved.
 *
 * Source: backend/src/utils/deep-resolver.ts:L1-L28
 * Source: backend/src/utils/serializer.interceptor.ts:L14
 */
async function deepResolvePromises(input) {
  // Await and return a resolved Promise.
  if (input instanceof Promise) {
    return await input;
  }

  // Resolve arrays element-by-element via Promise.all (recursive).
  if (Array.isArray(input)) {
    const resolvedArray = await Promise.all(input.map(deepResolvePromises));
    return resolvedArray;
  }

  // Preserve Date instances as-is (do not treat as a plain object).
  if (input instanceof Date) {
    return input;
  }

  // Recurse over plain-object keys, awaiting each property value.
  // KNOWN ISSUE: Map/Set reach this branch but Object.keys ignores their entries, yielding {}.
  if (typeof input === 'object' && input !== null) {
    const keys = Object.keys(input);
    const resolvedObject = {};

    for (const key of keys) {
      const resolvedValue = await deepResolvePromises(input[key]);
      resolvedObject[key] = resolvedValue;
    }

    return resolvedObject;
  }

  // Primitives, null, and functions pass through unchanged.
  return input;
}

export default deepResolvePromises;
