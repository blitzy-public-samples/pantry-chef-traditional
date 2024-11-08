part of 'camera_bloc.dart';

sealed class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

class PictureTaken extends CameraEvent {
  final XFile image;

  const PictureTaken({required this.image});

  @override
  List<Object> get props => [image];
}
