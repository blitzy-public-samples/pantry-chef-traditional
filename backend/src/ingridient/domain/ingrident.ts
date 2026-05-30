// NOTE: Filename 'ingrident.ts' carries an additional typo (distinct from the
// 'Ingridient' class spelling). Preserved verbatim. Do not rename.
// NOTE: 'Ingridient' class spelling preserved verbatim across the backend codebase. Do not rename.

import { Reference } from 'src/common/types';
/**
 * Domain entity representing an Ingridient (spelling preserved verbatim).
 *
 * Carries id, name, category: Reference, optional quantity, optional unit
 * Reference, optional expirationDate, optional imageUrl, confidence,
 * timestamps, and optional deletedAt for soft-delete.
 *
 * Note: this file lives at `domain/ingrident.ts` — the filename carries
 * an additional typo distinct from the `Ingridient` class spelling.
 */
export class Ingridient {
  id: string;
  name: string;
  category: Reference;
  quantity?: number;
  unit?: Reference;
  expirationDate?: Date;
  imageUrl?: string;
  confidence: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}
