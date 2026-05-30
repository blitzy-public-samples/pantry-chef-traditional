// NOTE: 'PantryIngridient' spelling preserved verbatim across the backend codebase. Do not rename.
import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Domain entity for a pantry item (spelling preserved verbatim).
 *
 * Returned by PantryService methods and consumed by PantryController to
 * shape API responses. Carries an embedded `Ingridient` reference (singular
 * field name preserved verbatim — note that this is a denormalized link to
 * the ingredient catalogue at src/ingridient/, and that the path itself
 * uses the preserved misspelling 'ingridient').
 *
 * Fields:
 * - id            — Mongoose _id as string
 * - ingridient    — Ingridient (spelling preserved) reference
 * - userId        — Scalar String userId from JWT (NOT ObjectId)
 * - quantity      — Numeric quantity
 * - unit          — Unit string
 * - expirationDate — Optional Date
 * - location      — Enum: 'fridge' | 'freezer' | 'pantry'
 * - createdAt     — Mongoose timestamp
 * - updatedAt     — Mongoose timestamp
 * - deletedAt     — Optional soft-delete marker (but see ../README.md
 *                   § Known Limitations: the repository softDelete is
 *                   physically destructive and does not currently set
 *                   this field)
 *
 * See ../../../../DATA_MODEL.md § PantryIngridient for the full schema-level
 * reference (including Mongoose @Schema, @Prop, and index declarations).
 */
export class PantryIngridient {
  id: string;
  ingridient: Ingridient;
  userId: string;
  quantity: number;
  unit: string;
  expirationDate?: Date;
  location: 'fridge' | 'freezer' | 'pantry';
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}
