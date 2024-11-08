import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/usecases/index.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<PictureTaken>((event, emit) async {
      ImageProcessingUsecase useCase = ImageProcessingUsecase();
      try {
        Ingredient result = await useCase(event.image);
        emit(ImagedProcessed(foundIngredient: result));
      } catch (err) {
        emit(ImageProcessingError());
      }
    });
  }
}
