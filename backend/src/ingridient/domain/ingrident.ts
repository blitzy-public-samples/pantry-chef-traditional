import { Reference } from 'src/common/types';
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
