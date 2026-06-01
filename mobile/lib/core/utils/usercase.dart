// NOTE: 'usercase.dart' filename typo preserved verbatim; UseCase/UseCaseWithParams are correct.
/// Base contract for parameterless use cases in the clean-architecture domain layer.
///
/// Invoke via the callable-class syntax: `final result = await myUseCase();` (Dart treats
/// a class with a `call` method as if the instance itself were callable). The generic
/// [Type] is the awaited result type.
///
/// Implementations live as concrete classes such as `LoginUseCase`,
/// `GetUserProfileUseCase`, etc., typically in `features/<feature>/domain/usecases/`.
abstract class UseCase<Type> {
  /// Executes the use case and returns the awaited result.
  ///
  /// Invoked via the callable-class syntax: `final result = await useCase();`.
  /// Implementations should encapsulate a single application-level operation;
  /// errors should be thrown, not returned.
  Future<Type> call();
}

/// Base contract for parameterized use cases in the clean-architecture domain layer.
///
/// Invoke via the callable-class syntax with an argument:
/// `final result = await myUseCase(params);`. The generic [Type] is the awaited result
/// type; [Params] is the input type passed to [call].
///
/// Implementations live as concrete classes such as `LoginWithEmailUseCase`,
/// `SaveRecipeUseCase`, etc.
abstract class UseCaseWithParams<Type, Params> {
  /// Executes the use case with [params] and returns the awaited result.
  ///
  /// Invoked via the callable-class syntax with an argument:
  /// `final result = await useCase(params);`.
  Future<Type> call(Params params);
}
