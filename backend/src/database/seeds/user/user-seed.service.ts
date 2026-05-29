import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import bcrypt from 'bcryptjs';
import { Model } from 'mongoose';
import { UserSchemaClass } from 'src/users/infrastructure/document/entities/user.schema';

/**
 * Seed service that drops the Users collection and inserts two canonical
 * test users with hardcoded ObjectIds for deterministic local development.
 *
 * Inserted records (Source: this file:L29-L56):
 * - admin (email admin@example.com, _id 672c8442346b022fbd49c179)
 * - john.doe (email john.doe@example.com, _id 672c73612ae468b9bb358205)
 *
 * Both passwords are bcrypt-hashed from the literal 'secret'.
 *
 * Destructive on every run — see backend/src/database/README.md
 * § Known Limitations.
 */
@Injectable()
export class UserSeedService {
  constructor(
    @InjectModel(UserSchemaClass.name)
    private readonly model: Model<UserSchemaClass>,
  ) {}

  /**
   * Drop the Users collection via Mongoose's native collection.drop().
   *
   * @returns Promise<void>
   */
  async dropCollection() {
    await this.model.collection.drop();
  }

  // TODO(prod): Seed runner drops collections (dropCollection) before reseeding.
  // TODO(prod): Gate behind explicit flag before production.
  /**
   * Drop the Users collection and re-insert the seed users.
   *
   * Idempotent: re-running produces the same ObjectIds and password hashes,
   * but destroys any user data created in between runs.
   *
   * @returns Promise<void>
   */
  async run() {
    await this.dropCollection();

    const admin = await this.model.findOne({
      email: 'admin@example.com',
    });

    if (!admin) {
      const salt = await bcrypt.genSalt();
      const password = await bcrypt.hash('secret', salt);

      const data = new this.model({
        _id: '672c8442346b022fbd49c179',
        email: 'admin@example.com',
        password: password,
      });
      await data.save();
    }

    const user = await this.model.findOne({
      email: 'john.doe@example.com',
    });

    if (!user) {
      const salt = await bcrypt.genSalt();
      const password = await bcrypt.hash('secret', salt);

      const data = new this.model({
        _id: '672c73612ae468b9bb358205',
        email: 'john.doe@example.com',
        password: password,
        preferences: {
          allergies: ['672b64e0098d5177afddb33f'],
          dislikedIngredients: ['672b64e0098d5177afddb341'],
        },
      });

      await data.save();
    }
  }
}
