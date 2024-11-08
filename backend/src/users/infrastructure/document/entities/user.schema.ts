import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude, Expose } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';

export type UserSchemaDocument = HydratedDocument<UserSchemaClass>;

export class Preferences {
  @Prop({ type: [String], default: [] })
  dietary?: string[];

  @Prop({ type: [String], default: [] })
  allergies?: string[];

  @Prop({ type: [String], default: [] })
  dislikedIngredients?: string[];

  @Prop({ type: Number, default: 0 })
  cookingTime?: number;
}

@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class UserSchemaClass extends EntityDocumentHelper {
  @Prop({
    type: String,
    unique: true,
  })
  @Expose({ toPlainOnly: true })
  email: string | null;

  @Exclude({ toPlainOnly: true })
  @Prop()
  password?: string;

  @Prop({
    type: Preferences,
    default: {
      dietary: [],
      allergies: [],
      dislikedIngredients: [],
      cookingTime: 0,
    },
  })
  preferences?: Preferences;

  @Prop({
    type: [String],
    default: [],
  })
  favoriteRecipes?: string[];

  @Prop({ type: [String], default: [] })
  recentSearches?: string[];

  @Prop({ default: now })
  createdAt: Date;

  @Prop({ default: now })
  updatedAt: Date;

  @Prop()
  deletedAt?: Date;
}

export const UserSchema = SchemaFactory.createForClass(UserSchemaClass);
