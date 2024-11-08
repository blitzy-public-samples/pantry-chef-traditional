import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import bcrypt from 'bcryptjs';
import { Model } from 'mongoose';
import { UserSchemaClass } from 'src/users/infrastructure/document/entities/user.schema';

@Injectable()
export class UserSeedService {
  constructor(
    @InjectModel(UserSchemaClass.name)
    private readonly model: Model<UserSchemaClass>,
  ) {}

  async dropCollection() {
    await this.model.collection.drop();
  }

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
