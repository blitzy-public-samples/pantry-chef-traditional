import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { RecipeSchemaClass } from 'src/recipe/infrastructure/document/entities/recipe.schema';

@Injectable()
export class RecipeSeedService {
  constructor(
    @InjectModel(RecipeSchemaClass.name)
    private readonly model: Model<RecipeSchemaClass>,
  ) {}

  async dropCollection() {
    await this.model.collection.drop();
  }

  async run() {
    await this.dropCollection();

    const recipesData: any = [
      {
        title: 'Spaghetti Bolognese',
        description:
          'A classic Italian pasta dish with a rich, flavorful meat sauce.',
        ingridientList: [
          {
            ingridient: '672b64e0098d5177afddb340', // minced beef
            amount: 500,
            unit: 'g',
            required: true,
            substitutes: ['ground turkey', 'mushrooms'],
          },
          {
            ingridient: '672b64e0098d5177afddb341', // onions
            amount: 200,
            unit: 'g',
            required: true,
          },
        ],
        instructions: [
          {
            step: 1,
            description: 'Heat oil in a pan and cook onions until golden.',
            timer: 5,
          },
          {
            step: 2,
            description: 'Add minced beef and cook until browned.',
            timer: 10,
          },
          {
            step: 3,
            description: 'Stir in tomato sauce and simmer for 15 minutes.',
            timer: 15,
          },
        ],
        prepTime: 10,
        cookTime: 30,
        servings: 4,
        difficulty: 'medium',
        tags: ['pasta', 'Italian', 'main course'],
        imageUrl: 'https://example.com/images/spaghetti_bolognese.jpg',
        matchScore: 0.9,
      },
      {
        title: 'Greek Salad',
        description:
          'A refreshing salad with cucumbers, tomatoes, and feta cheese.',
        ingridientList: [
          {
            ingridient: '672b64e0098d5177afddb32f', // cucumber
            amount: 2,
            unit: 'pcs',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb33f', // feta cheese
            amount: 100,
            unit: 'g',
            required: true,
          },
        ],
        instructions: [
          {
            step: 1,
            description: 'Chop vegetables and place in a large bowl.',
          },
          { step: 2, description: 'Add feta cheese and olives.' },
          {
            step: 3,
            description:
              'Drizzle with olive oil and season with salt and pepper.',
          },
        ],
        prepTime: 10,
        cookTime: 0,
        servings: 2,
        difficulty: 'easy',
        tags: ['salad', 'Greek', 'vegetarian'],
        imageUrl: 'https://example.com/images/greek_salad.jpg',
        matchScore: 0.8,
      },
      {
        title: 'Pizza Margherita',
        description:
          'Classic pizza with a thin crust, tomato sauce, mozzarella, and fresh basil.',
        ingridientList: [
          {
            ingridient: '672b64e0098d5177afddb337', // flour
            amount: 500,
            unit: 'g',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb338', // tomato sauce
            amount: 150,
            unit: 'ml',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb339', // mozzarella cheese
            amount: 200,
            unit: 'g',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb33a', // basil
            amount: 10,
            unit: 'g',
            required: false,
          },
        ],
        instructions: [
          {
            step: 1,
            description: 'Prepare the dough and let it rise for 1 hour.',
          },
          {
            step: 2,
            description: 'Roll out the dough and spread tomato sauce on top.',
          },
          {
            step: 3,
            description:
              'Add mozzarella and basil, then bake in a preheated oven at 250°C for 10-15 minutes.',
          },
        ],
        prepTime: 15,
        cookTime: 15,
        servings: 4,
        difficulty: 'medium',
        tags: ['pizza', 'Italian', 'main course'],
        imageUrl: 'https://example.com/images/pizza_margherita.jpg',
        matchScore: 0.85,
      },
      {
        title: 'Caesar Salad',
        description:
          'A classic Caesar salad with crisp romaine lettuce, creamy dressing, and crunchy croutons.',
        ingridientList: [
          {
            ingridient: '672b64e0098d5177afddb33b', // romaine lettuce
            amount: 1,
            unit: 'head',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb33c', // Parmesan cheese
            amount: 50,
            unit: 'g',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb33d', // croutons
            amount: 100,
            unit: 'g',
            required: true,
          },
          {
            ingridient: '672b64e0098d5177afddb33e', // Caesar dressing
            amount: 50,
            unit: 'ml',
            required: true,
          },
        ],
        instructions: [
          {
            step: 1,
            description: 'Chop romaine lettuce and place it in a large bowl.',
          },
          { step: 2, description: 'Add Parmesan cheese and croutons.' },
          {
            step: 3,
            description:
              'Drizzle with Caesar dressing and toss gently to combine.',
          },
        ],
        prepTime: 10,
        cookTime: 0,
        servings: 2,
        difficulty: 'easy',
        tags: ['salad', 'Caesar', 'appetizer'],
        imageUrl: 'https://example.com/images/caesar_salad.jpg',
        matchScore: 0.92,
      },
    ];

    await this.model.insertMany(recipesData);
  }
}
