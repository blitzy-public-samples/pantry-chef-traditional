/**
 * Page/limit inputs for pagination; consumed by `infinityPagination` to derive
 * `hasNextPage` (it compares `data.length === options.limit`).
 * Source: backend/src/utils/infinity-pagination.ts:L31
 */
export interface IPaginationOptions {
  // 1-based page index requested by the caller.
  page: number;
  // Maximum number of items per page; also used to compute hasNextPage.
  limit: number;
}
