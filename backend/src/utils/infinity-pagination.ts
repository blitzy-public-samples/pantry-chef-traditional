import { IPaginationOptions } from './types/pagination-options';
import { InfinityPaginationResultType } from './types/infinity-pagination-result.type';

/**
 * Generic adapter that wraps a page of already-fetched results into the
 * immutable infinite-pagination response shape `InfinityPaginationResultType<T>`
 * (`{ data, hasNextPage }`).
 *
 * `hasNextPage` is derived purely from page fullness: it is `true` when the page
 * is full (`data.length === options.limit`), i.e. a full page is assumed to imply
 * that at least one more page exists. This length-based heuristic does not consult
 * a total-count query, so an exactly-full final page can still report `true`.
 *
 * @typeParam T - The element type of the paginated collection.
 * @param data - The array of items for the current page.
 * @param options - The `IPaginationOptions` (`page`, `limit`) used to derive
 *   `hasNextPage`.
 * @returns A `Readonly<{ data, hasNextPage }>` where `hasNextPage` is `true` when
 *   the page is full.
 *
 * Source: backend/src/utils/types/pagination-options.ts:L6
 * Source: backend/src/utils/types/infinity-pagination-result.type.ts:L7
 */
export const infinityPagination = <T>(
  data: T[],
  options: IPaginationOptions,
): InfinityPaginationResultType<T> => {
  return {
    data,
    // Full page (length === limit) implies another page may exist.
    hasNextPage: data.length === options.limit,
  };
};
