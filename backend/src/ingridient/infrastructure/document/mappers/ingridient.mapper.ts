import { Ingridient } from '../../../domain/ingrident';
import { IngridientSchemaClass } from '../entities/ingridient.schema';

/**
 * Centralizes conversion between persisted ingredient documents and the
 * `Ingridient` domain entity so mapping rules stay in one place.
 *
 * The misspelling `Ingridient` is an intentional, preserved identifier.
 */
export class IngridientMapper {
  /**
   * Maps a persistence document to the `Ingridient` domain entity.
   *
   * @param raw the `IngridientSchemaClass` document read from MongoDB.
   * @returns the equivalent `Ingridient` domain object (maps `_id` to `id`,
   *   copies scalar fields, and rebuilds the `category`/`unit` references).
   */
  static toDomain(raw: IngridientSchemaClass): Ingridient {
    const ingridient = new Ingridient();

    // Convert the Mongo ObjectId to the domain's string id.
    ingridient.id = raw._id.toString();
    ingridient.name = raw.name;
    // Rebuild the category reference, or null when absent.
    ingridient.category = raw.category
      ? { id: raw.category.id, name: raw.category.name }
      : null;
    ingridient.quantity = raw.quantity;
    // Rebuild the unit reference, or null when absent.
    ingridient.unit = raw.unit
      ? { id: raw.unit.id, name: raw.unit.name }
      : null;
    ingridient.expirationDate = raw.expirationDate;
    ingridient.imageUrl = raw.imageUrl;
    ingridient.confidence = raw.confidence;
    ingridient.createdAt = raw.createdAt;
    ingridient.updatedAt = raw.updatedAt;
    ingridient.deletedAt = raw.deletedAt;

    return ingridient;
  }

  /**
   * Maps an `Ingridient` domain entity to a partial persistence document.
   *
   * @param ingridient the domain object to convert.
   * @returns a `Partial<IngridientSchemaClass>` suitable for create/update.
   */
  static toPersistence(ingridient: Ingridient): Partial<IngridientSchemaClass> {
    const ingridientEntity: Partial<IngridientSchemaClass> = {};

    // Copy id to _id only when present and already a string.
    if (ingridient.id && typeof ingridient.id === 'string') {
      ingridientEntity._id = ingridient.id;
    }
    ingridientEntity.name = ingridient.name;
    // Flatten the category reference to { id, name }, or null when absent.
    ingridientEntity.category = ingridient.category
      ? { id: ingridient.category.id, name: ingridient.category.name }
      : null;
    ingridientEntity.quantity = ingridient.quantity;
    // Flatten the unit reference to { id, name }, or null when absent.
    ingridientEntity.unit = ingridient.unit
      ? { id: ingridient.unit.id, name: ingridient.unit.name }
      : null;
    ingridientEntity.expirationDate = ingridient.expirationDate;
    ingridientEntity.imageUrl = ingridient.imageUrl;
    ingridientEntity.confidence = ingridient.confidence;
    ingridientEntity.createdAt = ingridient.createdAt;
    ingridientEntity.updatedAt = ingridient.updatedAt;
    ingridientEntity.deletedAt = ingridient.deletedAt;

    return ingridientEntity;
  }
}
