/// Standard contract for a parameterless asynchronous domain or
/// application operation. Exposes a single [call] returning `Future<Type>`.
///
/// Base abstraction implemented by concrete use cases across features
/// (for example recipe, pantry, profile, and ingredient operations).
///
abstract class UseCase<Type> {
  /// Executes the operation and completes with the `Future<Type>` result.
  ///
  Future<Type> call();
}

/// Contract for an asynchronous operation that accepts [params] of type
/// `Params` and returns a `Future<Type>`.
///
/// Base abstraction implemented by concrete parameterized use cases across
/// features (for example login, signup, recipe matching, and pantry edits).
///
abstract class UseCaseWithParams<Type, Params> {
  /// Executes the operation with [params] and completes with the
  /// `Future<Type>` result.
  ///
  Future<Type> call(Params params);
}
