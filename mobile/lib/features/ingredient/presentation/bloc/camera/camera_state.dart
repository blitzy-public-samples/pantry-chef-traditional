part of 'camera_bloc.dart';

sealed class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object> get props => [];
}

final class CameraInitial extends CameraState {}

final class ImagedProcessed extends CameraState {
  final Ingredient foundIngredient;

  const ImagedProcessed({required this.foundIngredient});
}

final class ImageProcessingError extends CameraState {}
