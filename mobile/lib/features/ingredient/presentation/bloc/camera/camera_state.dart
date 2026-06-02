part of 'camera_bloc.dart';

/// Closed state hierarchy for the camera capture-and-recognize flow.
sealed class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object> get props => [];
}

/// Idle/initial state before any image capture occurs.
final class CameraInitial extends CameraState {}

// KNOWN ISSUE: class name 'ImagedProcessed' is a preserved
// misspelling (do NOT rename to 'ImageProcessed'); stable identifier.
/// Success state carrying the recognized [foundIngredient].
final class ImagedProcessed extends CameraState {
  final Ingredient foundIngredient;

  const ImagedProcessed({required this.foundIngredient});
}

/// Error state emitted when image processing throws.
final class ImageProcessingError extends CameraState {}
