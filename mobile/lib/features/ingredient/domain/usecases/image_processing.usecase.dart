import 'package:camera/camera.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

class ImageProcessingUsecase implements UseCaseWithParams<Ingredient, XFile> {
  @override
  Future<Ingredient> call(XFile image) {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.processImage(image);
  }
}
