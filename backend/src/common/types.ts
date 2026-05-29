// NOTE: 'Ingridient', 'IngridientSchemaClass' identifiers referenced in JSDoc preserved verbatim across the backend codebase. Do not rename.

/**
 * Shared type alias for denormalized reference caching.
 *
 * Used across feature schemas to embed an { id, name } pair where joining
 * at read time would be expensive. The `name` field is a denormalized
 * snapshot — see README § Known Limitations for drift considerations.
 *
 * Consumers include:
 * - IngridientSchemaClass.category (spelling preserved verbatim)
 * - IngridientSchemaClass.unit
 * - Hardcoded creation-data arrays returned by
 *   GET /api/v1/ingredient/creation-data
 *   (Source: backend/src/ingridient/ingridient.controller.ts:L52-L71)
 *
 * @example
 * const category: Reference = { id: '1', name: 'spice' };
 * const unit: Reference = { id: '3', name: 'kg' };
 */
export type Reference = {
  id: string;
  name: string;
};
