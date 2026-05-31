part of 'camera_bloc.dart';

/// Sealed base class for all events handled by `CameraBloc`.
///
/// Currently has a single concrete subclass, `PictureTaken`. Extends
/// `Equatable` so BLoC's default deduplication treats two events as equal when
/// their `props` lists are equal.
sealed class CameraEvent extends Equatable {
  /// Default const constructor; allows subclasses to be `const`-constructed.
  const CameraEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched by `IngredientCameraDetecting` immediately after
/// `CameraController.takePicture()` returns a successfully captured frame.
///
/// Carries the captured [image] (an `XFile` from the `camera` package) which
/// `CameraBloc` forwards to `ImageProcessingUsecase` for backend AI resolution.
class PictureTaken extends CameraEvent {
  /// The captured image file from the device camera.
  ///
  /// Wraps a path to the file in the platform's temp directory.
  final XFile image;

  /// Creates a `PictureTaken` event carrying the supplied [image]; [image] is
  /// required.
  const PictureTaken({required this.image});

  @override
  List<Object> get props => [image];
}
