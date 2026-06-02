/** `T` unified with `never`; `T | never` reduces to `T` (a never-augmented alias). */
export type OrNeverType<T> = T | never;
