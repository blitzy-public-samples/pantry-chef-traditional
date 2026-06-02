import { IngridientMapper } from 'src/ingridient/infrastructure/document/mappers/ingridient.mapper';
import { PantryIngridient } from '../../../domain/pantryIngridient';
import { PantryIngridientSchemaClass } from '../entities/pantryIngridient.schema';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

/**
 * Maps between the Mongoose `PantryIngridientSchemaClass` and the
 * `PantryIngridient` domain model.
 */
export class PantryIngridientMapper {
  /**
   * Converts a persistence record into a `PantryIngridient` domain object.
   * @param raw the Mongoose `PantryIngridientSchemaClass` document.
   * @returns the mapped `PantryIngridient`.
   */
  static toDomain(raw: PantryIngridientSchemaClass): PantryIngridient {
    const pantryIngredient = new PantryIngridient();
    // _id -> id string conversion (null when absent)
    pantryIngredient.id = raw._id ? raw._id.toString() : null;
    pantryIngredient.userId = raw.userId;
    // nested ingridient mapped via IngridientMapper.toDomain
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

  /**
   * Converts a `PantryIngridient` domain object into a partial persistence
   * record.
   * @param pantryIngredient the domain model.
   * @returns a `Partial<PantryIngridientSchemaClass>` suitable for insert/update.
   */
  static toPersistence(
    pantryIngredient: PantryIngridient,
  ): Partial<PantryIngridientSchemaClass> {
    const pantryIngridientEntity: Partial<PantryIngridientSchemaClass> = {};

    // keep string id as _id when present
    if (pantryIngredient.id && typeof pantryIngredient.id === 'string') {
      pantryIngridientEntity._id = pantryIngredient.id;
    }
    // nested ingridient mapped via IngridientMapper.toPersistence
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
