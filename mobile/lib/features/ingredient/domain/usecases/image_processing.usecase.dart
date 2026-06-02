import 'package:camera/camera.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case that sends a captured image to the backend AI
/// vision pipeline and returns the recognized [Ingredient].
///
/// Implements [UseCaseWithParams] (params: [XFile], result:
/// [Ingredient]).
/// Source: core/utils/usercase.dart:L19
class ImageProcessingUsecase implements UseCaseWithParams<Ingredient, XFile> {
  /// Recognizes an ingredient from [image] and returns the resulting
  /// [Ingredient]. [image] is a `camera` package [XFile].
  @override
  Future<Ingredient> call(XFile image) {
    // Resolve the concrete repository behind the IngredientRepository
    // contract (stateless; a fresh impl per call).
    IngredientRepository repo = IngredientRepositoryImpl();
    // Delegate the upload + recognition to repo.processImage.
    return repo.processImage(image);
  }
}
