import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
// NOTE: 'PantryIngridientSchemaClass', 'PantryIngridientSchema', 'PantryIngridient'
// NOTE: spellings preserved verbatim across the backend codebase. Do not rename.
import { PantryIngridientSchemaClass } from 'src/pantry/infrastructure/document/entities/pantryIngridient.schema';

/**
 * Seed service for PantryIngridients (spelling preserved verbatim).
 *
 * Drops the PantryIngridients collection and re-inserts 6 seed pantry
 * items assigned to john.doe (userId 672c73612ae468b9bb358205) with
 * location values from the {freezer, pantry, fridge} enum.
 *
 * Items: minced beef, onions, milk, romaine lettuce, croutons, feta cheese.
 *
 * Destructive on every run — see backend/src/database/README.md
 * § Known Limitations.
 */
@Injectable()
export class PantrySeedService {
  constructor(
    @InjectModel(PantryIngridientSchemaClass.name)
    private readonly model: Model<PantryIngridientSchemaClass>,
  ) {}

  /**
   * Drop the PantryIngridients collection (spelling preserved verbatim).
   *
   * @returns Promise<void>
   */
  async dropCollection() {
    await this.model.collection.drop();
  }

  // TODO(prod): Seed runner drops collections (dropCollection) before reseeding.
  // TODO(prod): Gate behind explicit flag before production.
  /**
   * Drop the PantryIngridients collection (spelling preserved verbatim)
   * and re-insert the 6 seed pantry items via insertMany.
   *
   * Seed payloads reference both the seeded john.doe userId and seeded
   * Ingridient ObjectIds; therefore this service must run AFTER
   * UserSeedService and IngridientSeedService (orchestrated by run-seed.ts).
   *
   * @returns Promise<void>
   */
  async run() {
    await this.dropCollection();

    const pantryData = [
      {
        ingridient: '672b64e0098d5177afddb340', // minced beef
        quantity: 1,
        userId: '672c73612ae468b9bb358205',
        unit: 'kg',
        expirationDate: new Date('2024-11-25T00:00:00.000Z'),
        location: 'freezer',
      },
      {
        ingridient: '672b64e0098d5177afddb341', // onions
        quantity: 3,
        userId: '672c73612ae468b9bb358205',
        unit: 'pcs',
        expirationDate: new Date('2024-12-05T00:00:00.000Z'),
        location: 'pantry',
      },
      {
        ingridient: '672b64e0098d5177afddb333', // milk
        quantity: 2,
        userId: '672c73612ae468b9bb358205',
        unit: 'l',
        expirationDate: new Date('2024-11-10T00:00:00.000Z'),
        location: 'fridge',
      },
      {
        ingridient: '672b64e0098d5177afddb33b', // romaine lettuce
        quantity: 1,
        userId: '672c73612ae468b9bb358205',
        unit: 'head',
        expirationDate: new Date('2024-11-15T00:00:00.000Z'),
        location: 'fridge',
      },
      {
        ingridient: '672b64e0098d5177afddb33d', // croutons
        quantity: 0.2,
        userId: '672c73612ae468b9bb358205',
        unit: 'kg',
        expirationDate: new Date('2024-12-05T00:00:00.000Z'),
        location: 'pantry',
      },
      {
        ingridient: '672b64e0098d5177afddb33f', // feta cheese
        quantity: 0.1,
        userId: '672c73612ae468b9bb358205',
        unit: 'kg',
        expirationDate: new Date('2025-01-10T00:00:00.000Z'),
        location: 'fridge',
      },
    ];

    await this.model.insertMany(pantryData);
  }
}
