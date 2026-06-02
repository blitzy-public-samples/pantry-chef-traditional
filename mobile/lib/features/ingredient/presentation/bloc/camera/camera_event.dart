part of 'camera_bloc.dart';

/// Closed event hierarchy for the camera capture-and-recognize flow.
sealed class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

/// Carries the captured [image] (an `XFile`) to be processed.
class PictureTaken extends CameraEvent {
  final XFile image;

  const PictureTaken({required this.image});

  @override
  List<Object> get props => [image];
}
