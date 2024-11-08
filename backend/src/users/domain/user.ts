export class User {
  id: number | string;
  email: string | null;
  password?: string;
  preferences?: {
    dietary?: string[];
    allergies?: string[];
    dislikedIngredients?: string[];
    cookingTime?: number;
  };
  favoriteRecipes?: string[];
  recentSearches?: string[];
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date;
}
