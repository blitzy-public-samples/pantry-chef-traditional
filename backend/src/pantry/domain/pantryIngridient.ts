import { Ingridient } from 'src/ingridient/domain/ingrident';

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
