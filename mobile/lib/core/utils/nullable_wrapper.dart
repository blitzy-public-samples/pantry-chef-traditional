/// A generic immutable container that distinguishes a present value
/// (which may itself be `null`) from an absent one.
///
/// Useful for `copyWith`-style partial updates where `null` is a meaningful
/// value rather than "leave unchanged"; wrapping an argument in a [Nullable]
/// signals an explicit intent to set the field, even to `null`.
///
/// Source: mobile/lib/core/utils/nullable_wrapper.dart:L1
class Nullable<T> {
  /// The wrapped, possibly-null value of type `T?`.
  ///
  /// Source: mobile/lib/core/utils/nullable_wrapper.dart:L2
  final T? value;
  /// Creates a constant [Nullable] that wraps the provided [value].
  ///
  /// Source: mobile/lib/core/utils/nullable_wrapper.dart:L3
  const Nullable.value(this.value);
}
