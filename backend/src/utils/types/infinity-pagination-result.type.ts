/**
 * Immutable (Readonly) infinite-pagination response shape: a `data` page (`T[]`) plus a
 * `hasNextPage` boolean flag. Produced by `infinityPagination`, which sets
 * `hasNextPage = data.length === options.limit` (a length-based heuristic).
 * Source: backend/src/utils/infinity-pagination.ts:L31
 */
export type InfinityPaginationResultType<T> = Readonly<{
  data: T[];
  hasNextPage: boolean;
}>;
