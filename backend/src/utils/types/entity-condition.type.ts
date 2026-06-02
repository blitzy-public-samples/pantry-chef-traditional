/** Per-field filter; each optional property of `T` is a single value, array, or `undefined`. */
export type EntityCondition<T> = {
  [P in keyof T]?: T[P] | T[P][] | undefined;
};
