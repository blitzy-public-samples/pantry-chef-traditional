import { Reference } from 'src/common/types';

/**
 * Canonical, persistence-agnostic ingredient domain entity.
 *
 * Shared shape consumed across the controller, service, repository, and
 * mapper layers of the ingredient module. Imports `Reference` ({ id, name })
 * from `src/common/types` for the `category` and `unit` fields.
 *
 * Source: backend/src/ingridient/domain/ingrident.ts:L2
 */
export class Ingridient {
  // Unique identifier of the ingredient record.
  id: string;
  // Human-readable ingredient name.
  name: string;
  // Category reference ({ id, name }) classifying the ingredient.
  category: Reference;
  // Optional quantity on hand.
  quantity?: number;
  // Optional unit-of-measure reference ({ id, name }).
  unit?: Reference;
  // Optional expiration date for the ingredient.
  expirationDate?: Date;
  // Optional URL of the ingredient image.
  imageUrl?: string;
  // Detection confidence score in the 0-1 range.
  confidence: number;
  // Timestamp when the record was created.
  createdAt: Date;
  // Timestamp when the record was last updated.
  updatedAt: Date;
  // Soft-delete timestamp set by the repository's soft delete.
  deletedAt?: Date;
}
