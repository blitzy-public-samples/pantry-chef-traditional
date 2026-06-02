import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude, Expose } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';

// Hydrated Mongoose document type alias for UserSchemaClass.
export type UserSchemaDocument = HydratedDocument<UserSchemaClass>;

/**
 * Embedded user-preferences subdocument capturing dietary preference tags,
 * allergy tags, disliked-ingredient tags, and a preferred cooking time.
 * Stored inline on the user document (not a separate collection) and given
 * a default object on `UserSchemaClass.preferences`.
 */
export class Preferences {
  // Dietary preference tags (e.g. vegan, halal); defaults to [].
  @Prop({ type: [String], default: [] })
  dietary?: string[];

  // Allergy tags to exclude from recommendations; defaults to [].
  @Prop({ type: [String], default: [] })
  allergies?: string[];

  // Disliked-ingredient tags to avoid; defaults to [].
  @Prop({ type: [String], default: [] })
  dislikedIngredients?: string[];

  // Preferred cooking time in minutes; defaults to 0.
  @Prop({ type: Number, default: 0 })
  cookingTime?: number;
}

/**
 * Mongoose user document and persistence contract for the users domain.
 *
 * Extends `EntityDocumentHelper`, which provides the serialized string `_id`
 * (the base-class `@Transform({ toPlainOnly: true })` stringifies the Mongo
 * ObjectId on serialization).
 * Source: backend/src/utils/document-entity-helper.ts:L4-L17
 *
 * The schema enables `timestamps: true` (auto `createdAt`/`updatedAt`) and
 * `toJSON: { virtuals: true, getters: true }` (virtuals and getters are
 * included in JSON output).
 *
 * The generated runtime schema is exported as `UserSchema` (see L71) and
 * registered by `DocumentUserPersistenceModule` via `MongooseModule.forFeature`.
 */
@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class UserSchemaClass extends EntityDocumentHelper {
  // User email; carries a unique index (unique: true) and is exposed on
  // serialization via @Expose({ toPlainOnly: true }).
  @Prop({
    type: String,
    unique: true,
  })
  @Expose({ toPlainOnly: true })
  email: string | null;

  // Stores the bcrypt password hash; declares @Exclude({ toPlainOnly: true }), but
  // KNOWN ISSUE: no global serializer runs it, so password IS returned in responses.
  @Exclude({ toPlainOnly: true })
  @Prop()
  password?: string;

  // Embedded Preferences subdocument; default object
  // { dietary: [], allergies: [], dislikedIngredients: [], cookingTime: 0 }.
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

  // Favorited recipe ids; defaults to [].
  @Prop({
    type: [String],
    default: [],
  })
  favoriteRecipes?: string[];

  // Recent search terms; defaults to [].
  @Prop({ type: [String], default: [] })
  recentSearches?: string[];

  // Creation timestamp; defaults to mongoose now.
  @Prop({ default: now })
  createdAt: Date;

  // Last-update timestamp; defaults to mongoose now.
  @Prop({ default: now })
  updatedAt: Date;

  // Soft-delete timestamp metadata.
  // KNOWN ISSUE: repository softDelete performs a HARD delete (deleteOne) and never sets this.
  // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L172-L174
  @Prop()
  deletedAt?: Date;
}

// Generated Mongoose schema for the users collection, built from UserSchemaClass.
export const UserSchema = SchemaFactory.createForClass(UserSchemaClass);
