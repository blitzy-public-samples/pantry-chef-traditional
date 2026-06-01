import 'package:camera/camera.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case that uploads a captured photo to the backend AI vision
/// endpoint and returns the resolved [Ingredient].
///
/// Implements [UseCaseWithParams]`<Ingredient, XFile>` from
/// `package:pantry_chef/core/utils/usercase.dart` (the `usercase` file name
/// carries a verbatim-preserved typo and must not be renamed). `XFile` is the
/// file abstraction from `package:camera/camera.dart`.
///
/// Delegates to `IngredientRepositoryImpl().processImage(image)` — instantiated
/// fresh on every call (no dependency injection, no caching) — which uploads
/// the file as multipart form data (form field `image`) to `POST /api/ai/vision`.
///
/// Production-readiness caveat: `POST /api/ai/vision` is currently **unguarded**
/// — `backend/src/ai/ai.controller.ts:L12-L43` declares the route without
/// `@UseGuards(AuthGuard('jwt'))`. The mobile client still sends the JWT bearer
/// header via `DioClient`, but the backend does not verify it. See
/// `backend/src/ai/README.md` and `PRODUCTION_READINESS.md` for the centralized
/// production-readiness gap inventory.
class ImageProcessingUsecase implements UseCaseWithParams<Ingredient, XFile> {
  /// Uploads [image] to the backend AI vision endpoint and returns the
  /// resolved [Ingredient].
  ///
  /// [image] is an [XFile] from the `camera` package — typically a photo
  /// captured by the in-app camera (or selected from the gallery) and forwarded
  /// by `CameraBloc` on its `PictureTaken` event.
  ///
  /// Returns a [Future] resolving to an [Ingredient] built via
  /// `Ingredient.fromJson(response)` in the data layer. A fresh
  /// [IngredientRepositoryImpl] is instantiated on each call (no DI, no caching).
  ///
  /// May throw when Google Cloud Vision cannot resolve the image: the backend
  /// returns an empty JSON object `{}`, so `Ingredient.fromJson({})` throws on
  /// the missing required fields. The upstream `CameraBloc` catches that error,
  /// emits `ImageProcessingError`, and routes the user to the manual add form.
  @override
  Future<Ingredient> call(XFile image) {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.processImage(image);
  }
}
