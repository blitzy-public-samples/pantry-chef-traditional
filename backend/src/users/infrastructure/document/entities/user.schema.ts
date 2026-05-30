import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude, Expose } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';

/**
 * Hydrated Mongoose document type for UserSchemaClass.
 */
export type UserSchemaDocument = HydratedDocument<UserSchemaClass>;

/**
 * Embedded subdocument storing the user's dietary preferences,
 * allergies, disliked ingredients, and `cookingTime` constraint.
 *
 * Stored inline within each `UserSchemaClass` document — not a
 * separate Mongo collection. Schema-level defaults are applied:
 * empty arrays for `dietary`, `allergies`, and `dislikedIngredients`,
 * and `0` for `cookingTime`.
 *
 * Consumed by `RecipeService.matches` to drive the four pre-filter
 * steps of the recipe matching pipeline (`$nin` on `allergies` and
 * `dislikedIngredients`, `$all` on `dietary`, `$lte` on
 * `cookingTime`). See `../../../../../../ARCHITECTURE.md`
 * § Recipe Matching Pipeline and `../../../../../../DATA_MODEL.md`
 * § Preferences for the canonical schema reference.
 */
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

/**
 * Mongoose schema class for the `users` MongoDB collection.
 *
 * Extends `EntityDocumentHelper` (from
 * `src/utils/document-entity-helper.ts`) which applies
 * `@Transform({ toPlainOnly: true })` on `_id` to serialize Mongo
 * ObjectIds as strings during `class-transformer.plainToInstance`
 * style conversions. `@Schema({ timestamps: true })` instructs
 * Mongoose to populate `createdAt` and `updatedAt` automatically; the
 * explicit `@Prop({ default: now })` declarations on those fields
 * work in concert with the schema-level option.
 *
 * Notable field-level conventions (canonical reference:
 * `../../../../../../DATA_MODEL.md` § User):
 *  - `email` carries the `unique: true` index option.
 *  - `password` is decorated with `@Exclude({ toPlainOnly: true })`
 *    so it never appears in serialized JSON responses, but it IS
 *    populated when the document is hydrated from Mongo (e.g.,
 *    during the bcrypt comparison in `AuthService.validateLogin`).
 *  - `preferences` is an embedded `Preferences` subdocument with
 *    default empty arrays and `cookingTime: 0`.
 *  - `deletedAt` is the soft-delete timestamp slot — but note that
 *    `UsersDocumentRepository.softDelete` currently calls `deleteOne`
 *    rather than writing this field. See `../../../README.md`
 *    § Known Limitations.
 */
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

/**
 * Compiled Mongoose schema for UserSchemaClass, produced by SchemaFactory
 * and registered with MongooseModule.forFeature.
 */
export const UserSchema = SchemaFactory.createForClass(UserSchemaClass);
