/// Generic wrapper that signals an explicit "set-to-null" intent in `copyWith`
/// patterns, as distinct from "no value supplied".
///
/// Without this wrapper, a `copyWith({T? value})` cannot tell two cases apart:
/// the caller passing nothing (keep the existing value) versus the caller
/// explicitly passing `null` (overwrite the field with `null`). Wrapping the
/// argument as `Nullable<T>?` resolves the ambiguity: passing nothing leaves
/// the field unchanged, while passing `Nullable.value(null)` clears it.
///
/// Consumed by bloc states that need to clear nullable fields. For example,
/// `AuthState.copyWith` accepts `errorMessage: Nullable<String>?` so callers can
/// reset the error message. See
/// `mobile/lib/features/authentication/presentation/bloc/auth/auth_state.dart`.
class Nullable<T> {
  /// The wrapped value, which may itself be null.
  final T? value;
  /// Constructs a [Nullable] wrapper holding [value]; the named constructor
  /// `value` is part of the type's expressive API.
  ///
  /// Use `Nullable.value(someValue)` to wrap a concrete value, or
  /// `Nullable.value(null)` to build the explicit "clear this field" sentinel.
  /// Declared `const` so wrappers can appear in const contexts and as default
  /// parameter values.
  const Nullable.value(this.value);
}
