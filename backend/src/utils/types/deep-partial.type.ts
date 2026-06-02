/** Recursively makes every property of `T` (and nested objects) optional; for partial updates. */
export type DeepPartial<T> = {
  [P in keyof T]?: DeepPartial<T[P]>;
};
