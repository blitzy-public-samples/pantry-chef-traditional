import { Ingridient } from '../../../domain/ingrident';
import { IngridientSchemaClass } from '../entities/ingridient.schema';

export class IngridientMapper {
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
