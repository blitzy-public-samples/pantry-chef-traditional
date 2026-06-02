import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Domain model for a pantry ingredient — the canonical in-app shape of a
 * record the user has on hand.
 */
export class PantryIngridient {
  // Unique identifier (string).
  id: string;
  // The referenced Ingridient catalog entry (spelling preserved).
  ingridient: Ingridient;
  // Owner of this pantry entry (user id).
  userId: string;
  // Numeric amount on hand.
  quantity: number;
  // Measurement unit (string).
  unit: string;
  // Optional expiry date for perishable items.
  expirationDate?: Date;
  // Storage location; one of: 'fridge', 'freezer', or 'pantry'.
  location: 'fridge' | 'freezer' | 'pantry';
  // Lifecycle timestamp: when the entry was created.
  createdAt: Date;
  // Lifecycle timestamp: when the entry was last updated.
  updatedAt: Date;
  // Optional soft-delete marker.
  // KNOWN ISSUE: the document repository's softDelete() hard-deletes via
  // deleteOne(), so this field is declared but never set by the delete path.
  // Source: pantryIngridient.repository.ts:L184-L186
  deletedAt?: Date;
}
