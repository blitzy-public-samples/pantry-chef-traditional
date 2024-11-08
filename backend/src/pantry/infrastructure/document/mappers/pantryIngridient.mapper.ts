import { IngridientMapper } from 'src/ingridient/infrastructure/document/mappers/ingridient.mapper';
import { PantryIngridient } from '../../../domain/pantryIngridient';
import { PantryIngridientSchemaClass } from '../entities/pantryIngridient.schema';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

export class PantryIngridientMapper {
  static toDomain(raw: PantryIngridientSchemaClass): PantryIngridient {
    const pantryIngredient = new PantryIngridient();
    pantryIngredient.id = raw._id ? raw._id.toString() : null;
    pantryIngredient.userId = raw.userId;
    if (raw.ingridient) {
      pantryIngredient.ingridient = IngridientMapper.toDomain(raw.ingridient);
    }
    pantryIngredient.quantity = raw.quantity;
    pantryIngredient.unit = raw.unit;
    pantryIngredient.expirationDate = raw.expirationDate;
    pantryIngredient.location = raw.location;
    pantryIngredient.createdAt = raw.createdAt;
    pantryIngredient.updatedAt = raw.updatedAt;
    pantryIngredient.deletedAt = raw.deletedAt;

    return pantryIngredient;
  }

  static toPersistence(
    pantryIngredient: PantryIngridient,
  ): Partial<PantryIngridientSchemaClass> {
    const pantryIngridientEntity: Partial<PantryIngridientSchemaClass> = {};

    if (pantryIngredient.id && typeof pantryIngredient.id === 'string') {
      pantryIngridientEntity._id = pantryIngredient.id;
    }
    if (pantryIngredient.ingridient) {
      pantryIngridientEntity.ingridient = IngridientMapper.toPersistence(
        pantryIngredient.ingridient,
      ) as IngridientSchemaClass;
    }
    pantryIngridientEntity.userId = pantryIngredient.userId;
    pantryIngridientEntity.quantity = pantryIngredient.quantity;
    pantryIngridientEntity.unit = pantryIngredient.unit;
    pantryIngridientEntity.expirationDate = pantryIngredient.expirationDate;
    pantryIngridientEntity.location = pantryIngredient.location;
    pantryIngridientEntity.createdAt = pantryIngredient.createdAt;
    pantryIngridientEntity.updatedAt = pantryIngredient.updatedAt;
    pantryIngridientEntity.deletedAt = pantryIngredient.deletedAt;

    return pantryIngridientEntity;
  }
}
