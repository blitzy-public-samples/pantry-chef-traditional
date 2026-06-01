import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude, Expose } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';

// Hydrated Mongoose document type alias for UserSchemaClass.
// Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L6
export type UserSchemaDocument = HydratedDocument<UserSchemaClass>;

/**
 * Embedded user-preferences subdocument capturing dietary preference tags,
 * allergy tags, disliked-ingredient tags, and a preferred cooking time.
 * Stored inline on the user document (not a separate collection) and given
 * a default object on `UserSchemaClass.preferences`.
 * Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L8
 */
export class Preferences {
  // Dietary preference tags (e.g. vegan, halal); defaults to []. Source: .../user.schema.ts:L9-L10
  @Prop({ type: [String], default: [] })
  dietary?: string[];

  // Allergy tags to exclude from recommendations; defaults to [].
  // Source: .../user.schema.ts:L12-L13
  @Prop({ type: [String], default: [] })
  allergies?: string[];

  // Disliked-ingredient tags to avoid; defaults to []. Source: .../user.schema.ts:L15-L16
  @Prop({ type: [String], default: [] })
  dislikedIngredients?: string[];

  // Preferred cooking time in minutes; defaults to 0. Source: .../user.schema.ts:L18-L19
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
 * Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L22-L28
 *
 * The generated runtime schema is exported as `UserSchema` (see L71) and
 * registered by `DocumentUserPersistenceModule` via `MongooseModule.forFeature`.
 * Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L29
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
  // serialization via @Expose({ toPlainOnly: true }). Source: .../user.schema.ts:L30-L35
  @Prop({
    type: String,
    unique: true,
  })
  @Expose({ toPlainOnly: true })
  email: string | null;

  // Stores the bcrypt password hash; OMITTED from serialized output via
  // @Exclude({ toPlainOnly: true }). Source: .../user.schema.ts:L37-L39
  @Exclude({ toPlainOnly: true })
  @Prop()
  password?: string;

  // Embedded Preferences subdocument; default object
  // { dietary: [], allergies: [], dislikedIngredients: [], cookingTime: 0 }.
  // Source: .../user.schema.ts:L41-L50
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

  // Favorited recipe ids; defaults to []. Source: .../user.schema.ts:L52-L56
  @Prop({
    type: [String],
    default: [],
  })
  favoriteRecipes?: string[];

  // Recent search terms; defaults to []. Source: .../user.schema.ts:L58-L59
  @Prop({ type: [String], default: [] })
  recentSearches?: string[];

  // Creation timestamp; defaults to mongoose now. Source: .../user.schema.ts:L61-L62
  @Prop({ default: now })
  createdAt: Date;

  // Last-update timestamp; defaults to mongoose now. Source: .../user.schema.ts:L64-L65
  @Prop({ default: now })
  updatedAt: Date;

  // Soft-delete timestamp metadata. Source: .../user.schema.ts:L67-L68
  // KNOWN ISSUE: repository softDelete performs a HARD delete (deleteOne) and never sets this.
  // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L81
  @Prop()
  deletedAt?: Date;
}

// Generated Mongoose schema for the users collection, built from UserSchemaClass.
// Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L71
export const UserSchema = SchemaFactory.createForClass(UserSchemaClass);
