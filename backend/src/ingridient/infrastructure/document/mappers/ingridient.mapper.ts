import { Ingridient } from '../../../domain/ingrident';
import { IngridientSchemaClass } from '../entities/ingridient.schema';

// NOTE: 'Ingridient', 'IngridientMapper', 'IngridientSchemaClass' spellings preserved verbatim. Do not rename.

/**
 * Maps IngridientSchemaClass (Mongoose document) to the Ingridient
 * domain entity (defined in ../../../domain/ingrident.ts — note the
 * additional typo in the filename) and back.
 *
 * Spellings preserved verbatim across the backend codebase.
 */
export class IngridientMapper {
  /**
   * Convert a Mongoose IngridientSchemaClass document into the Ingridient
   * domain entity (spelling preserved verbatim).
   *
   * Stringifies `_id` into `Ingridient.id`. Copies `name`, `category`
   * (Reference), `quantity`, `unit` (Reference, may be null), `expirationDate`,
   * `imageUrl`, `confidence`, timestamps, and `deletedAt` as-is.
   *
   * @param raw Hydrated IngridientSchemaClass document from Mongoose.
   * @returns Ingridient domain entity.
   */
  static toDomain(raw: IngridientSchemaClass): Ingridient {
    const ingridient = new Ingridient();

    ingridient.id = raw._id.toString();
    ingridient.name = raw.name;
    ingridient.category = raw.category
      ? { id: raw.category.id, name: raw.category.name }
      : null;
    ingridient.quantity = raw.quantity;
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
   * Convert an Ingridient domain entity into a partial IngridientSchemaClass
   * payload for Mongoose persistence (spelling preserved verbatim).
   *
   * When `ingridient.id` is a non-empty string, assigns it to `_id` to
   * support upserts. Otherwise relies on Mongoose to generate one. Flattens
   * `Reference` shapes for `category` and `unit`.
   *
   * @param ingridient Ingridient domain entity.
   * @returns Partial IngridientSchemaClass suitable for `new Model(payload)`.
   */
  static toPersistence(ingridient: Ingridient): Partial<IngridientSchemaClass> {
    const ingridientEntity: Partial<IngridientSchemaClass> = {};

    if (ingridient.id && typeof ingridient.id === 'string') {
      ingridientEntity._id = ingridient.id;
    }
    ingridientEntity.name = ingridient.name;
    ingridientEntity.category = ingridient.category
      ? { id: ingridient.category.id, name: ingridient.category.name }
      : null;
    ingridientEntity.quantity = ingridient.quantity;
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
