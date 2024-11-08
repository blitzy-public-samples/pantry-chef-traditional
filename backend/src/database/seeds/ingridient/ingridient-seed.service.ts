import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

@Injectable()
export class IngridientSeedService {
  constructor(
    @InjectModel(IngridientSchemaClass.name)
    private readonly model: Model<IngridientSchemaClass>,
  ) {}

  async dropCollection() {
    await this.model.collection.drop();
  }

  async run() {
    await this.dropCollection();

    const ingredientsData = [
      // Spice category
      {
        _id: '672b64e0098d5177afddb32d',
        name: 'black pepper',
        category: { id: 1, name: 'spice' },
        quantity: 0.5,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2025-01-01T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/black_pepper.jpg',
        confidence: 0.98,
      },
      {
        _id: '672b64e0098d5177afddb32e',
        name: 'cinnamon',
        category: { id: 1, name: 'spice' },
        quantity: 0.3,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2025-02-01T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/cinnamon.jpg',
        confidence: 0.95,
      },
      // Vegetable category
      {
        _id: '672b64e0098d5177afddb32f',
        name: 'cucumber',
        category: { id: 2, name: 'vegetable' },
        quantity: 2,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-12-01T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/cucumber.jpg',
        confidence: 1,
      },
      {
        _id: '672b64e0098d5177afddb330',
        name: 'carrot',
        category: { id: 2, name: 'vegetable' },
        quantity: 3,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-11-20T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/carrot.jpg',
        confidence: 0.95,
      },
      // Fruit category
      {
        _id: '672b64e0098d5177afddb331',
        name: 'apple',
        category: { id: 3, name: 'fruit' },
        quantity: 10,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-11-15T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/apple.jpg',
        confidence: 1,
      },
      {
        _id: '672b64e0098d5177afddb332',
        name: 'banana',
        category: { id: 3, name: 'fruit' },
        quantity: 8,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-11-25T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/banana.jpg',
        confidence: 0.8,
      },
      // Dairy category
      {
        _id: '672b64e0098d5177afddb333',
        name: 'milk',
        category: { id: 4, name: 'dairy' },
        quantity: 5,
        unit: { id: 6, name: 'l' },
        expirationDate: new Date('2024-11-10T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/milk.jpg',
        confidence: 0.9,
      },
      {
        _id: '672b64e0098d5177afddb334',
        name: 'cheese',
        category: { id: 4, name: 'dairy' },
        quantity: 1,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-12-15T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/cheese.jpg',
        confidence: 0.95,
      },
      // Protein category
      {
        _id: '672b64e0098d5177afddb335',
        name: 'chicken breast',
        category: { id: 5, name: 'protein' },
        quantity: 3,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-11-12T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/chicken_breast.jpg',
        confidence: 0.97,
      },
      {
        _id: '672b64e0098d5177afddb336',
        name: 'tofu',
        category: { id: 5, name: 'protein' },
        quantity: 2,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-12-20T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/tofu.jpg',
        confidence: 0.9,
      },
      // Ingredients for Pizza and Caesar Salad
      {
        _id: '672b64e0098d5177afddb337',
        name: 'flour',
        category: { id: 6, name: 'baking' },
        quantity: 10,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2025-01-10T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/flour.jpg',
        confidence: 0.99,
      },
      {
        _id: '672b64e0098d5177afddb338',
        name: 'tomato sauce',
        category: { id: 7, name: 'sauce' },
        quantity: 5,
        unit: { id: 6, name: 'l' },
        expirationDate: new Date('2024-12-01T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/tomato_sauce.jpg',
        confidence: 0.98,
      },
      {
        _id: '672b64e0098d5177afddb339',
        name: 'mozzarella cheese',
        category: { id: 4, name: 'dairy' },
        quantity: 2,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-12-20T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/mozzarella.jpg',
        confidence: 0.95,
      },
      {
        _id: '672b64e0098d5177afddb33a',
        name: 'basil',
        category: { id: 8, name: 'herb' },
        quantity: 0.1,
        unit: { id: 2, name: 'g' },
        expirationDate: new Date('2024-11-30T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/basil.jpg',
        confidence: 0.95,
      },
      {
        _id: '672b64e0098d5177afddb33b',
        name: 'romaine lettuce',
        category: { id: 9, name: 'vegetable' },
        quantity: 5,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-11-15T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/romaine_lettuce.jpg',
        confidence: 0.98,
      },
      {
        _id: '672b64e0098d5177afddb33c',
        name: 'Parmesan cheese',
        category: { id: 4, name: 'dairy' },
        quantity: 1,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2025-01-01T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/parmesan.jpg',
        confidence: 0.96,
      },
      {
        _id: '672b64e0098d5177afddb33d',
        name: 'croutons',
        category: { id: 10, name: 'bread' },
        quantity: 0.5,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-12-05T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/croutons.jpg',
        confidence: 0.9,
      },
      {
        _id: '672b64e0098d5177afddb33e',
        name: 'Caesar dressing',
        category: { id: 7, name: 'sauce' },
        quantity: 1,
        unit: { id: 6, name: 'l' },
        expirationDate: new Date('2024-12-15T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/caesar_dressing.jpg',
        confidence: 0.92,
      },
      {
        _id: '672b64e0098d5177afddb33f',
        name: 'feta cheese',
        category: { id: 4, name: 'dairy' },
        quantity: 1,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2025-01-10T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/feta_cheese.jpg',
        confidence: 0.93,
      },
      {
        _id: '672b64e0098d5177afddb340',
        name: 'minced beef',
        category: { id: 5, name: 'protein' },
        quantity: 2,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-11-25T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/minced_beef.jpg',
        confidence: 0.94,
      },
      {
        _id: '672b64e0098d5177afddb341',
        name: 'onions',
        category: { id: 2, name: 'vegetable' },
        quantity: 3,
        unit: { id: 1, name: 'kg' },
        expirationDate: new Date('2024-12-05T00:00:00.000Z'),
        imageUrl: 'https://example.com/images/onions.jpg',
        confidence: 0.96,
      },
    ];

    await this.model.insertMany(ingredientsData);
  }
}
