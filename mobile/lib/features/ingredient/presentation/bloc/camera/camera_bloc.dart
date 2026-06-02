import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/usecases/index.dart';

part 'camera_event.dart';
part 'camera_state.dart';

/// BLoC that turns a captured camera image into an ingredient result.
///
/// Handles [PictureTaken] by running [ImageProcessingUsecase] on the
/// image; emits [ImagedProcessed] on success or [ImageProcessingError]
/// on failure. Starts in [CameraInitial].
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<PictureTaken>((event, emit) async {
      // Instantiate the image-processing use case per request.
      ImageProcessingUsecase useCase = ImageProcessingUsecase();
      try {
        // Await recognition of event.image (an XFile) -> Ingredient.
        Ingredient result = await useCase(event.image);
        // Emit success with the recognized ingredient.
        emit(ImagedProcessed(foundIngredient: result));
      } catch (err) {
        // Any failure maps to a generic processing-error state.
        emit(ImageProcessingError());
      }
    });
  }
}
