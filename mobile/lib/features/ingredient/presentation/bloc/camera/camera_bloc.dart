import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/usecases/index.dart';

part 'camera_event.dart';
part 'camera_state.dart';

/// BLoC for the ingredient camera capture flow.
///
/// Handles a single event, `PictureTaken`, by invoking `ImageProcessingUsecase`
/// to upload the captured `XFile` to the backend AI vision endpoint and resolve
/// it to an `Ingredient`. Emits `ImagedProcessed(foundIngredient: result)` on
/// success or `ImageProcessingError()` on any caught exception. Used
/// exclusively by the `IngredientCameraDetecting` screen, which provides it
/// via `BlocProvider` and listens for both states to navigate to
/// `Navigation.ingredientAdding` (with the resolved Ingredient as argument on
/// success, or without arguments on error).
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  /// Creates a `CameraBloc` initialized to the `CameraInitial` state.
  ///
  /// Registers the `on<PictureTaken>` handler inline.
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
