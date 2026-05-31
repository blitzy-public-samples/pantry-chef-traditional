part of 'camera_bloc.dart';

/// Sealed base class for all states emitted by `CameraBloc`.
///
/// Three concrete subclasses model the lifecycle: `CameraInitial` (idle, no
/// capture yet), `ImagedProcessed` (success — Ingredient resolved), and
/// `ImageProcessingError` (failure during upload or AI resolution). Extends
/// `Equatable` for default state-deduplication semantics.
sealed class CameraState extends Equatable {
  /// Default const constructor; allows subclasses to be `const`-constructed.
  const CameraState();

  @override
  List<Object> get props => [];
}

/// Initial state of `CameraBloc` before any image has been captured.
///
/// Set by the constructor's `super(CameraInitial())` call.
final class CameraInitial extends CameraState {}

/// Emitted by `CameraBloc` when `ImageProcessingUsecase` successfully resolves
/// the captured image into an `Ingredient` via the backend AI vision endpoint.
///
/// The `IngredientCameraDetecting` screen listens for this state and navigates
/// to `Navigation.ingredientAdding` passing [foundIngredient] as the route
/// argument to pre-fill the form.
final class ImagedProcessed extends CameraState {
  /// The `Ingredient` resolved from the captured image by the backend AI vision
  /// pipeline.
  final Ingredient foundIngredient;

  /// Creates an `ImagedProcessed` state carrying the resolved [foundIngredient];
  /// [foundIngredient] is required.
  const ImagedProcessed({required this.foundIngredient});
}

/// Emitted by `CameraBloc` when `ImageProcessingUsecase` throws — e.g.,
/// network error, backend returned an empty body, JSON mapping failure.
///
/// The `IngredientCameraDetecting` screen listens for this and navigates to
/// `Navigation.ingredientAdding` WITHOUT an argument so the user can fill in
/// the form manually.
final class ImageProcessingError extends CameraState {}
