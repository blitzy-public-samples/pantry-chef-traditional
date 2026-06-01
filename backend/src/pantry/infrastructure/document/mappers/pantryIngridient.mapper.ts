// NOTE: 'PantryIngridient', 'PantryIngridientSchemaClass' spellings preserved
// verbatim. Do not rename.
import { IngridientMapper } from 'src/ingridient/infrastructure/document/mappers/ingridient.mapper';
import { PantryIngridient } from '../../../domain/pantryIngridient';
import { PantryIngridientSchemaClass } from '../entities/pantryIngridient.schema';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

/**
 * Maps between the Mongoose PantryIngridientSchemaClass document and the
 * PantryIngridient domain entity (spelling preserved verbatim).
 *
 * Delegates the nested `ingridient` field mapping to IngridientMapper
 * (spelling preserved verbatim — note the embedded misspelling in
 * 'ingridient') to keep schema/document and domain boundaries consistent.
 */
export class PantryIngridientMapper {
  /**
   * Convert a Mongoose PantryIngridientSchemaClass document to the
   * PantryIngridient domain entity.
   *
   * Stringifies `_id` to populate `id`, and delegates the embedded
   * `ingridient` mapping to IngridientMapper.toDomain when present.
   *
   * @param raw Raw Mongoose schema document.
   * @returns Hydrated PantryIngridient domain entity.
   */
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

  /**
   * Convert a PantryIngridient domain entity into a partial
   * PantryIngridientSchemaClass payload ready for Mongoose persistence.
   *
   * Preserves a string `id` as `_id` (when present), and delegates the
   * embedded `ingridient` mapping to IngridientMapper.toPersistence.
   *
   * @param pantryIngredient Domain entity.
   * @returns Partial<PantryIngridientSchemaClass> ready for Mongoose.
   */
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
