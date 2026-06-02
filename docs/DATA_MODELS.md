# PantryChef Data Models Reference

This document is the **persistence-model reference** for the PantryChef
monorepo. It is **reference material**: neutral, present-tense, and
table-driven. It catalogs every persisted MongoDB/Mongoose entity on the
backend and every `@JsonSerializable` Dart model on the mobile client, with
field-level tables, declared indexes, the embedded/reference relationships
between entities, and the soft-delete-vs-hard-delete behavior matrix.

Each technical claim carries an inline `Source: <path>:<line>` citation, using
repository-root-relative paths, so that every statement is traceable to the
implementation. For the REST surface that returns these shapes, see
[./API_REFERENCE.md](./API_REFERENCE.md); for how the layers fit together, see
[./ARCHITECTURE.md](./ARCHITECTURE.md).

> This reference documents the models **as built**. Where runtime behavior
> diverges from a field name or a method name, the divergence is recorded with
> a `KNOWN ISSUE:` callout rather than corrected.

## Table of Contents

- [1. Overview](#1-overview)
- [2. Entity Relationship Diagram](#2-entity-relationship-diagram)
- [3. User and Embedded Preferences](#3-user-and-embedded-preferences)
- [4. Session](#4-session)
- [5. Ingridient](#5-ingridient)
- [6. PantryIngridient](#6-pantryingridient)
- [7. Recipe](#7-recipe)
- [8. Indexes](#8-indexes)
- [9. Soft-delete vs Hard-delete Matrix](#9-soft-delete-vs-hard-delete-matrix)
- [10. Mobile Dart Models](#10-mobile-dart-models)
- [11. Related Documentation](#11-related-documentation)

## 1. Overview

PantryChef persists data across two model layers: the **backend Mongoose
schemas** that define the MongoDB collections, and the **mobile Dart models**
that decode and encode the JSON exchanged with the REST API.

### Backend Mongoose schemas

The backend stores data in MongoDB accessed through Mongoose 8
(`Source: backend/package.json:L37` — `mongoose ^8.8.0`) via the
`@nestjs/mongoose` integration (`Source: backend/package.json:L30` —
`@nestjs/mongoose ^10.1.0`). Schemas live under
`backend/src/<module>/infrastructure/document/entities/*.schema.ts`.

Every collection-backing schema class extends `EntityDocumentHelper`
(`Source: backend/src/utils/document-entity-helper.ts:L15`), which exposes a
public `_id` whose value is serialized to a string through a `@Transform`
applied on plain serialization
(`Source: backend/src/utils/document-entity-helper.ts:L16-L30`). As a result,
every document exposes a string `_id` in its serialized JSON. Embedded
subdocument classes do not extend it — for example the recipe `IngridientList`
subdocument is a plain `@Schema()` class with no `EntityDocumentHelper` base
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L11-L12`).

The collection-backing classes are decorated with
`@Schema({ timestamps: true, toJSON: { virtuals: true, getters: true } })`,
which enables Mongoose timestamps and applies virtuals and getters on JSON
serialization (`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L48-L54`,
`Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L26`,
`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L26`,
`Source: backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L9-L15`).
The `Recipe` schema additionally declares a matching `toObject` option
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L76-L79`).
Because each schema sets `timestamps: true`, Mongoose maintains `createdAt` and
`updatedAt` at runtime. Most schema classes also declare these as explicit class
fields (with `default: now`) alongside a `deletedAt` field; `SessionSchemaClass`,
however, declares only `createdAt` and `deletedAt` as class fields and relies on
`timestamps: true` to supply `updatedAt`
(`Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L26,L32-L40`).

### Mobile Dart models

The mobile client models live under
`mobile/lib/features/<feature>/domain/models/*.dart`. Each model is annotated
`@JsonSerializable` and is decoded through `json_serializable`
(`Source: mobile/pubspec.yaml:L62` — `json_serializable ^6.7.1`) on top of
`json_annotation` (`Source: mobile/pubspec.yaml:L40` —
`json_annotation ^4.9.0`); the generated code is produced by `build_runner`
(`Source: mobile/pubspec.yaml:L63` — `build_runner ^2.4.6`). Most models
declare a `part '*.g.dart'` directive and expose a `fromJson` factory and a
`toJson` method that delegate to the generated `_$...FromJson` / `_$...ToJson`
functions; the sole exception is the deserialize-only `IngredientAddData`,
which exposes a `fromJson` factory but defines no `toJson`
(`Source: mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L31-L38`).
The Dart models mirror the JSON the backend serializes; the
field-by-field mapping appears in [Section 10](#10-mobile-dart-models).

> **Note on identifier spelling.** The backend module directory is spelled
> `ingridient/` and the embedded recipe subdocument class is named
> `IngridientList`; the mobile client mixes the correctly spelled `Ingredient`
> class with a misspelled field `ingridient`, a misspelled list field
> `ingridientList`, and a misspelled class `InstractionItem`. These spellings
> are stable identifiers and are reproduced exactly throughout this document
> (`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L26`,
> `Source: mobile/lib/features/recipe/domain/models/recipe.dart:L12-L13`).

## 2. Entity Relationship Diagram

The diagram below uses the **schema class names** exactly as they appear in the
backend code (`UserSchemaClass`, `SessionSchemaClass`, `IngridientSchemaClass`,
`PantryIngridientSchemaClass`, `RecipeSchemaClass`) together with the embedded
subdocument classes (`Preferences`, `IngridientList`, `Instruction`).
Composition (`*--`) marks an embedded subdocument; an arrow (`-->`) marks an
`ObjectId` reference to another collection.

```mermaid
classDiagram
    class UserSchemaClass {
        +string _id
        +string email
        +Preferences preferences
        +List~string~ favoriteRecipes
        +List~string~ recentSearches
        +Date createdAt
        +Date updatedAt
        +Date deletedAt
    }
    class Preferences {
        +List~string~ dietary
        +List~string~ allergies
        +List~string~ dislikedIngredients
        +number cookingTime
    }
    class SessionSchemaClass {
        +string _id
        +UserSchemaClass user
        +Date createdAt
        +Date deletedAt
    }
    class IngridientSchemaClass {
        +string _id
        +string name
        +Reference category
        +number quantity
        +Reference unit
        +Date expirationDate
        +string imageUrl
        +number confidence
        +Date createdAt
        +Date updatedAt
        +Date deletedAt
    }
    class PantryIngridientSchemaClass {
        +string _id
        +IngridientSchemaClass ingridient
        +number quantity
        +string userId
        +string unit
        +Date expirationDate
        +string location
        +Date createdAt
        +Date updatedAt
        +Date deletedAt
    }
    class RecipeSchemaClass {
        +string _id
        +string title
        +string description
        +List~IngridientList~ ingridientList
        +List~Instruction~ instructions
        +number prepTime
        +number cookTime
        +number servings
        +string difficulty
        +List~string~ tags
        +string imageUrl
        +number matchScore
        +Date createdAt
        +Date updatedAt
        +Date deletedAt
    }
    class IngridientList {
        +IngridientSchemaClass ingridient
        +number amount
        +string unit
        +boolean required
        +List~string~ substitutes
    }
    class Instruction {
        +number step
        +string description
        +number timer
    }
    UserSchemaClass *-- Preferences : embeds
    SessionSchemaClass --> UserSchemaClass : ref
    PantryIngridientSchemaClass --> IngridientSchemaClass : ref
    RecipeSchemaClass *-- "many" IngridientList : embeds
    IngridientList --> IngridientSchemaClass : ref
    RecipeSchemaClass *-- "many" Instruction : embeds
```

_Diagram sources: `Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L15-L108`,
`Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L26-L41`,
`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L26-L70`,
`Source: backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L21-L58`,
`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L12-L141`._

## 3. User and Embedded Preferences

The `User` collection is backed by `UserSchemaClass`, which extends
`EntityDocumentHelper`
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L55`).
It embeds a `Preferences` subdocument by value and tracks the user's favorite
recipes and recent searches as string arrays.

Owning module source: [`backend/src/users/`](../backend/src/users/).

### `UserSchemaClass`

| Field | Type | Notes | Source |
|---|---|---|---|
| `_id` | `string` | Inherited from `EntityDocumentHelper`; serialized to a string | `backend/src/utils/document-entity-helper.ts:L32` |
| `email` | `string \| null` | `unique: true`; carries `@Expose({ toPlainOnly: true })` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L58-L63` |
| `password` | `string?` | Declares `@Exclude({ toPlainOnly: true })`, but no global serializer (`ClassSerializerInterceptor`) is registered, so the bcrypt hash is returned in API responses (KNOWN ISSUE) | `backend/src/users/infrastructure/document/entities/user.schema.ts:L67-L69` |
| `preferences` | `Preferences` | Embedded subdocument; defaults to an object with empty arrays and `cookingTime: 0` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L73-L82` |
| `favoriteRecipes` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L85-L89` |
| `recentSearches` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L92-L93` |
| `createdAt` | `Date` | `default: now` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L96-L97` |
| `updatedAt` | `Date` | `default: now` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L100-L101` |
| `deletedAt` | `Date?` | Declared for soft deletion; see [Section 9](#9-soft-delete-vs-hard-delete-matrix) | `backend/src/users/infrastructure/document/entities/user.schema.ts:L106-L107` |

The schema declares a `deletedAt` field intended for soft deletion
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L106-L107`),
but the repository removes user documents physically; this divergence is
documented in [Section 9](#9-soft-delete-vs-hard-delete-matrix).

### `Preferences` (embedded subdocument)

`Preferences` is a plain class embedded inside `UserSchemaClass.preferences`
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L15-L31`).

| Field | Type | Notes | Source |
|---|---|---|---|
| `dietary` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L17-L18` |
| `allergies` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L21-L22` |
| `dislikedIngredients` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L25-L26` |
| `cookingTime` | `number?` | Default `0` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L29-L30` |

The mobile client mirrors this subdocument with its own `Preferences` model;
see [Section 10](#10-mobile-dart-models).

## 4. Session

The `Session` collection is backed by `SessionSchemaClass`, which extends
`EntityDocumentHelper`
(`Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L26`).
A session references the owning user by `ObjectId` and backs refresh-token
issuance.

Owning module source: [`backend/src/session/`](../backend/src/session/).

### `SessionSchemaClass`

| Field | Type | Notes | Source |
|---|---|---|---|
| `_id` | `string` | Inherited from `EntityDocumentHelper` | `backend/src/utils/document-entity-helper.ts:L32` |
| `user` | `UserSchemaClass` | `ObjectId` reference, `ref: 'UserSchemaClass'` | `backend/src/session/infrastructure/document/entities/session.schema.ts:L28-L29` |
| `createdAt` | `Date` | `default: now` | `backend/src/session/infrastructure/document/entities/session.schema.ts:L32-L33` |
| `deletedAt` | `Date` | Declared field; see [Section 9](#9-soft-delete-vs-hard-delete-matrix) | `backend/src/session/infrastructure/document/entities/session.schema.ts:L39-L40` |

The schema declares a secondary index on `{ user: 1 }`
(`Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L46`);
see [Section 8](#8-indexes).

## 5. Ingridient

> The backend module directory, schema file, and schema class preserve the
> spelling `Ingridient` (`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L26`).
> This spelling is a stable identifier and is reproduced exactly.

The `Ingridient` collection is backed by `IngridientSchemaClass`, which extends
`EntityDocumentHelper`
(`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L26`).
Several fields declare `@Exclude({ toPlainOnly: true })`. KNOWN ISSUE: no global
serializer (`ClassSerializerInterceptor`) is registered, so these decorators are
not enforced at runtime and the fields are returned in API responses.

Owning module source: [`backend/src/ingridient/`](../backend/src/ingridient/).

### `IngridientSchemaClass`

| Field | Type | Notes | Source |
|---|---|---|---|
| `_id` | `string` | Inherited from `EntityDocumentHelper` | `backend/src/utils/document-entity-helper.ts:L32` |
| `name` | `string` | Ingredient display name | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L28-L29` |
| `category` | `Reference` | Stored via `@Prop({ type: { id: Number, name: String } })`; `Reference` is `{ id: string; name: string }` | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L32-L33`, `backend/src/common/types.ts:L1-L4` |
| `quantity` | `number?` | Optional quantity | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L36-L37` |
| `unit` | `Reference?` | `@Exclude({ toPlainOnly: true })`; stored via `@Prop({ type: { id: Number, name: String } })` | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L40-L42` |
| `expirationDate` | `Date?` | `@Exclude({ toPlainOnly: true })` | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L45-L47` |
| `imageUrl` | `string?` | `@Exclude({ toPlainOnly: true })` | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L50-L52` |
| `confidence` | `number` | `@Exclude({ toPlainOnly: true })`; AI-detection confidence on the `0`–`1` scale | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L55-L57` |
| `createdAt` | `Date` | `default: now` | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L60-L61` |
| `updatedAt` | `Date` | `default: now` | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L64-L65` |
| `deletedAt` | `Date?` | Declared field | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L68-L69` |

The `Ingridient` schema declares no secondary index — `SchemaFactory.createForClass`
is the final statement and no `.index(...)` call follows
(`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L73-L75`);
see [Section 8](#8-indexes).

## 6. PantryIngridient

The `PantryIngridient` collection is backed by `PantryIngridientSchemaClass`,
which extends `EntityDocumentHelper`
(`Source: backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L21`).
Each pantry record references an `Ingridient` by `ObjectId`, is scoped to a user
through `userId`, and carries a storage `location` enum.

Owning module source: [`backend/src/pantry/`](../backend/src/pantry/).

### `PantryIngridientSchemaClass`

| Field | Type | Notes | Source |
|---|---|---|---|
| `_id` | `string` | Inherited from `EntityDocumentHelper` | `backend/src/utils/document-entity-helper.ts:L32` |
| `ingridient` | `IngridientSchemaClass` | `ObjectId` reference, `ref: 'IngridientSchemaClass'` | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L23-L24` |
| `quantity` | `number` | Amount on hand | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L27-L28` |
| `userId` | `string` | Owning user identifier | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L31-L32` |
| `unit` | `string` | Unit of measure | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L35-L36` |
| `expirationDate` | `Date?` | Optional expiry | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L39-L40` |
| `location` | `'fridge' \| 'freezer' \| 'pantry'` | Enum-constrained storage location | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L44-L45` |
| `createdAt` | `Date` | `default: now` | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L48-L49` |
| `updatedAt` | `Date` | `default: now` | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L52-L53` |
| `deletedAt` | `Date?` | Declared for soft deletion; see [Section 9](#9-soft-delete-vs-hard-delete-matrix) | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L56-L57` |

The schema declares a secondary index on `{ userId: 1 }`
(`Source: backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L65`);
see [Section 8](#8-indexes). The schema declares a `deletedAt` field, but the
repository removes pantry documents physically; see
[Section 9](#9-soft-delete-vs-hard-delete-matrix).

## 7. Recipe

The `Recipe` collection is backed by `RecipeSchemaClass`, which extends
`EntityDocumentHelper`
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L81`).
It composes two embedded subdocument arrays — `IngridientList` (the misspelling
is preserved) and `Instruction` — and is the only entity whose repository
honors the `deletedAt` soft-delete column at runtime
(see [Section 9](#9-soft-delete-vs-hard-delete-matrix)).

Owning module source: [`backend/src/recipe/`](../backend/src/recipe/).

### `IngridientList` (embedded subdocument)

`IngridientList` is declared with a bare `@Schema()` and compiled to
`IngridientListSchema`
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L11-L40`).
It is embedded as an array on `RecipeSchemaClass.ingridientList`.

| Field | Type | Notes | Source |
|---|---|---|---|
| `ingridient` | `IngridientSchemaClass` | `ObjectId` reference, `ref: 'IngridientSchemaClass'`, `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L14-L19` |
| `amount` | `number` | `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L22-L23` |
| `unit` | `string` | `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L26-L27` |
| `required` | `boolean` | `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L30-L31` |
| `substitutes` | `string[]?` | Default `[]` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L34-L35` |

### `Instruction` (embedded subdocument)

`Instruction` is a plain class embedded as an array on
`RecipeSchemaClass.instructions`
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L45-L57`).

| Field | Type | Notes | Source |
|---|---|---|---|
| `step` | `number` | `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L47-L48` |
| `description` | `string` | `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L51-L52` |
| `timer` | `number?` | Optional duration | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L55-L56` |

### `RecipeSchemaClass`

The recipe difficulty is constrained by the type alias
`Difficulty = 'easy' | 'medium' | 'hard'`
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L60`).

| Field | Type | Notes | Source |
|---|---|---|---|
| `_id` | `string` | Inherited from `EntityDocumentHelper` | `backend/src/utils/document-entity-helper.ts:L32` |
| `id` | `string` | `ObjectId`-typed property | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L83-L84` |
| `title` | `string` | `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L87-L88` |
| `description` | `string` | Free-text description | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L91-L92` |
| `ingridientList` | `IngridientList[]` | Embedded array, `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L95-L96` |
| `instructions` | `Instruction[]` | Embedded array, `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L99-L100` |
| `prepTime` | `number` | Preparation time | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L103-L104` |
| `cookTime` | `number` | Cooking time | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L107-L108` |
| `servings` | `number` | Serving count | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L111-L112` |
| `difficulty` | `Difficulty` | Enum `'easy' \| 'medium' \| 'hard'`, `required: true` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L115-L116` |
| `tags` | `string[]` | Tag list | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L119-L120` |
| `imageUrl` | `string` | Image URL | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L123-L124` |
| `matchScore` | `number?` | Optional; populated by the matching engine | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L127-L128` |
| `createdAt` | `Date` | `default: now` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L131-L132` |
| `updatedAt` | `Date` | `default: now` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L135-L136` |
| `deletedAt` | `Date?` | Honored at runtime (true soft delete); see [Section 9](#9-soft-delete-vs-hard-delete-matrix) | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L139-L140` |

The schema declares a secondary index on `{ title: 1 }`
(`Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L147`);
see [Section 8](#8-indexes).

## 8. Indexes

The table below lists every index declared on the backend schemas. The `_id`
index that MongoDB creates implicitly on every collection is omitted.

| Collection | Index | Source |
|---|---|---|
| Users | `email` unique | `backend/src/users/infrastructure/document/entities/user.schema.ts:L58-L63` |
| Sessions | `{ user: 1 }` | `backend/src/session/infrastructure/document/entities/session.schema.ts:L46` |
| PantryIngridients | `{ userId: 1 }` | `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L65` |
| Recipes | `{ title: 1 }` | `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L147` |
| Ingridients | (none declared) | `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts` |

The `email` uniqueness constraint is declared inline on the property with
`unique: true`
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L58-L63`),
while the `Session`, `PantryIngridient`, and `Recipe` secondary indexes are
declared with explicit `Schema.index(...)` calls.

## 9. Soft-delete vs Hard-delete Matrix

Each repository exposes a deletion operation, but the runtime behavior diverges
across entities. The `Recipe` and `Ingridient` repositories perform a true soft
delete by setting the `deletedAt` column; the `User`, `PantryIngridient`, and
`Session` repositories physically remove documents even though their schemas
declare a `deletedAt` field.

| Entity | Method | Actual behavior | Source |
|---|---|---|---|
| Recipe | `softDelete` | **True soft delete** — `updateOne({ _id: id }, { deletedAt: new Date() })`; reads filter on `deletedAt: null` | `backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L310-L311`; read filter `backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L127` |
| Ingridient | `softDelete` | **True soft delete** — `updateOne({ _id: id }, { deletedAt: new Date() })`; reads filter on `deletedAt: null` | `backend/src/ingridient/infrastructure/document/repositories/ingridient.repository.ts:L147-L150`; read filter `backend/src/ingridient/infrastructure/document/repositories/ingridient.repository.ts:L93` |
| User | `softDelete` | **KNOWN ISSUE: hard delete** — calls `deleteOne({ _id: id })` despite the schema's `deletedAt` field | `backend/src/users/infrastructure/document/repositories/user.repository.ts:L172-L174` (`deleteOne` at `L172`); schema field `backend/src/users/infrastructure/document/entities/user.schema.ts:L106-L107` |
| PantryIngridient | `softDelete` | **KNOWN ISSUE: hard delete** — calls `deleteOne({ _id: id })` despite the schema's `deletedAt` field | `backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L184-L186` (`deleteOne` at `L184`); schema field `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L56-L57` |
| Session | session removal | **KNOWN ISSUE: hard delete** — calls `deleteMany(transformedCriteria)` despite the schema's `deletedAt` field | `backend/src/session/infrastructure/document/repositories/session.repository.ts:L106`; schema field `backend/src/session/infrastructure/document/entities/session.schema.ts:L39-L40` |

**KNOWN ISSUE:** Only `Recipe` and `Ingridient` honor the `deletedAt` soft-delete
column at runtime
(`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L310-L312`,
`Source: backend/src/ingridient/infrastructure/document/repositories/ingridient.repository.ts:L147-L150`).
`User`, `PantryIngridient`, and `Session` documents are physically removed by
`deleteOne` / `deleteMany`, so their `deletedAt` columns are never populated
even though the schemas declare them
(`Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L164-L175`,
`Source: backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L179-L187`,
`Source: backend/src/session/infrastructure/document/repositories/session.repository.ts:L106`).
This matrix records the behavior as built; it does not prescribe a change.

## 10. Mobile Dart Models

The mobile client decodes API responses into `@JsonSerializable` Dart models.
Most models declare a `part '*.g.dart'` directive and expose a `fromJson`
factory plus a `toJson` method; the deserialize-only `IngredientAddData`
exposes a `fromJson` factory but no `toJson`. The tables below map each model
field to its
Dart type. Misspelled identifiers (`ingridient`, `ingridientList`,
`InstractionItem`) are reproduced exactly.

### `Recipe`

`Recipe` is annotated `@JsonSerializable`
(`Source: mobile/lib/features/recipe/domain/models/recipe.dart:L7-L58`). It
composes a list of `IngredientListItem` through the misspelled field
`ingridientList` and a list of the misspelled class `InstractionItem`.

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `id` | `String` | Recipe identifier | `mobile/lib/features/recipe/domain/models/recipe.dart:L16` |
| `title` | `String` | Recipe title | `mobile/lib/features/recipe/domain/models/recipe.dart:L18` |
| `description` | `String` | Description | `mobile/lib/features/recipe/domain/models/recipe.dart:L20` |
| `ingridientList` | `List<IngredientListItem>` | Misspelled field name (preserved) | `mobile/lib/features/recipe/domain/models/recipe.dart:L23` |
| `instructions` | `List<InstractionItem>` | Misspelled element class (preserved) | `mobile/lib/features/recipe/domain/models/recipe.dart:L26` |
| `prepTime` | `int` | Preparation time | `mobile/lib/features/recipe/domain/models/recipe.dart:L28` |
| `cookTime` | `int` | Cooking time | `mobile/lib/features/recipe/domain/models/recipe.dart:L30` |
| `servings` | `int` | Serving count | `mobile/lib/features/recipe/domain/models/recipe.dart:L32` |
| `difficulty` | `String` | Difficulty label | `mobile/lib/features/recipe/domain/models/recipe.dart:L34` |
| `tags` | `List<String>` | Tag list | `mobile/lib/features/recipe/domain/models/recipe.dart:L36` |
| `imageUrl` | `String` | Image URL | `mobile/lib/features/recipe/domain/models/recipe.dart:L38` |
| `matchScore` | `double?` | Commented "how well it matches available ingredients" | `mobile/lib/features/recipe/domain/models/recipe.dart:L41` |

**KNOWN ISSUE:** `Recipe.copyWith` accepts a `bool? inFavorite` parameter but
never applies it — `Recipe` declares no `inFavorite` field, and the method
reconstructs an identical copy from the existing fields, so the parameter is a
no-op (`Source: mobile/lib/features/recipe/domain/models/recipe.dart:L59-L81`).
This is recorded as built; no change is prescribed. For a working `copyWith`
by contrast, see [`Profile`](#profile) below
(`Source: mobile/lib/features/profile/domain/models/profile.dart:L47-L53`).

### `InstractionItem`

> The class name `InstractionItem` preserves the misspelling and is a stable
> identifier (`Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L11`).

`InstractionItem` is annotated `@JsonSerializable`
(`Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L5-L20`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `step` | `int` | Step ordinal | `mobile/lib/features/recipe/domain/models/instraction_item.dart:L13` |
| `description` | `String` | Step text | `mobile/lib/features/recipe/domain/models/instraction_item.dart:L15` |
| `timer` | `double?` | Optional timer | `mobile/lib/features/recipe/domain/models/instraction_item.dart:L17` |

### `IngredientListItem`

`IngredientListItem` is annotated `@JsonSerializable` and exposes the misspelled
field `ingridient`
(`Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L6-L25`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `ingridient` | `Ingredient` | Misspelled field name (preserved) | `mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L15` |
| `amount` | `double` | Quantity | `mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L17` |
| `unit` | `String` | Unit of measure | `mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L19` |
| `required` | `bool` | Whether the ingredient is required | `mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L21` |
| `substitutes` | `List<String>?` | Optional substitutes | `mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L23` |

### `Ingredient`

`Ingredient` is annotated `@JsonSerializable` and uses `@JsonKey` mappers for
its `category` and `unit` fields
(`Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L8-L31`).
This is the correctly spelled mobile class; the misspelling appears only on the
backend and on the `ingridient` field names that reference this class.

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `id` | `String` | Ingredient identifier | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L20` |
| `name` | `String` | Display name | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L22` |
| `category` | `Category` | `@JsonKey(toJson: Mappers.categoryToJson)` | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L26-L27` |
| `confidence` | `double` | AI-detection confidence | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L30` |
| `createdAt` | `String?` | Creation timestamp | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L32` |
| `quantity` | `double?` | Optional quantity | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L34` |
| `unit` | `Unit` | `@JsonKey(toJson: Mappers.unitToJson)` | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L38-L39` |
| `imageUrl` | `String?` | Optional image URL | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L41` |
| `expirationDate` | `String?` | Optional expiry | `mobile/lib/features/ingredient/domain/models/ingredient.dart:L43` |

### `Category`

`Category` is a lightweight `@JsonSerializable` reference value object used to
classify ingredients (for example, the categories offered by the
add-ingredient form). It is bidirectional, exposing both a `fromJson` factory
and a `toJson` method
(`Source: mobile/lib/features/ingredient/domain/models/category.dart:L10-L28`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `id` | `int` | Unique category identifier | `mobile/lib/features/ingredient/domain/models/category.dart:L13` |
| `name` | `String` | Category display name | `mobile/lib/features/ingredient/domain/models/category.dart:L15` |

### `Unit`

`Unit` is a lightweight `@JsonSerializable` reference value object used to label
ingredient quantities (for example, the units offered by the add-ingredient
form). Like `Category`, it is bidirectional, exposing both a `fromJson` factory
and a `toJson` method
(`Source: mobile/lib/features/ingredient/domain/models/unit.dart:L10-L28`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `id` | `int` | Unique unit identifier | `mobile/lib/features/ingredient/domain/models/unit.dart:L13` |
| `name` | `String` | Unit display name | `mobile/lib/features/ingredient/domain/models/unit.dart:L15` |

### `IngredientAddData`

`IngredientAddData` is the `@JsonSerializable` aggregate that wraps the
reference data used to populate the add-ingredient form — the available
`Category` and `Unit` options. It is the deserialized shape of the
`GET /api/ingredient/creation-data` response
(`Source: mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L15-L39`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `categories` | `List<Category>` | Selectable ingredient categories | `mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L20` |
| `units` | `List<Unit>` | Selectable measurement units | `mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L24` |

**KNOWN ISSUE:** `IngredientAddData` is deserialize-only — it defines a
`fromJson` factory but no `toJson` method, unlike the bidirectional `Category`
and `Unit` models. This is recorded as built; no change is prescribed
(`Source: mobile/lib/features/ingredient/domain/models/ingredient_add_data.dart:L31-L38`).

### `PantryItem`

`PantryItem` is annotated `@JsonSerializable` and exposes the misspelled field
`ingridient`
(`Source: mobile/lib/features/pantry/domain/models/pantry_item.dart:L17-L54`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `id` | `String` | Pantry item identifier | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L19` |
| `ingridient` | `Ingredient` | Misspelled field name (preserved) | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L24` |
| `quantity` | `double` | Amount on hand | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L26` |
| `location` | `String` | Storage location | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L28` |
| `createdAt` | `String` | Creation timestamp | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L30` |
| `updatedAt` | `String` | Update timestamp | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L32` |
| `expirationDate` | `String` | Expiry timestamp | `mobile/lib/features/pantry/domain/models/pantry_item.dart:L34` |

### `Profile`

`Profile` is annotated `@JsonSerializable` and uses a `@JsonKey` mapper for its
`preferences` field
(`Source: mobile/lib/features/profile/domain/models/profile.dart:L8-L34`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `id` | `String` | User identifier | `mobile/lib/features/profile/domain/models/profile.dart:L15` |
| `email` | `String` | User email | `mobile/lib/features/profile/domain/models/profile.dart:L17` |
| `favoriteRecipes` | `List<String>` | Favorite recipe identifiers | `mobile/lib/features/profile/domain/models/profile.dart:L19` |
| `recentSearches` | `List<String>` | Recent search terms | `mobile/lib/features/profile/domain/models/profile.dart:L21` |
| `preferences` | `Preferences` | `@JsonKey(toJson: Mappers.preferencesToJson)` | `mobile/lib/features/profile/domain/models/profile.dart:L23-L24` |

Unlike `Recipe.copyWith`, `Profile.copyWith({ List<String>? favoriteRecipes })`
applies its parameter via `favoriteRecipes ?? this.favoriteRecipes`, so it
produces an updated copy as expected
(`Source: mobile/lib/features/profile/domain/models/profile.dart:L47-L53`).

### `Preferences`

`Preferences` is annotated `@JsonSerializable` and mirrors the backend embedded
`Preferences` subdocument
(`Source: mobile/lib/features/profile/domain/models/preferences.dart:L6-L22`).

| Field | Dart type | Notes | Source |
|---|---|---|---|
| `dietary` | `List<String>` | Default `[]` | `mobile/lib/features/profile/domain/models/preferences.dart:L13` |
| `allergies` | `List<String>` | Default `[]` | `mobile/lib/features/profile/domain/models/preferences.dart:L15` |
| `dislikedIngredients` | `List<String>` | Default `[]` | `mobile/lib/features/profile/domain/models/preferences.dart:L17` |
| `cookingTime` | `double?` | Optional cooking time | `mobile/lib/features/profile/domain/models/preferences.dart:L19` |

## 11. Related Documentation

- [./API_REFERENCE.md](./API_REFERENCE.md) — REST endpoints that return and
  accept these model shapes.
- [./ARCHITECTURE.md](./ARCHITECTURE.md) — how the persistence layer fits into
  the backend and mobile architecture.

Entity-owning backend module sources:

- [`backend/src/users/`](../backend/src/users/) — `User` and embedded `Preferences`.
- [`backend/src/session/`](../backend/src/session/) — `Session`.
- [`backend/src/ingridient/`](../backend/src/ingridient/) — `Ingridient`.
- [`backend/src/pantry/`](../backend/src/pantry/) — `PantryIngridient`.
- [`backend/src/recipe/`](../backend/src/recipe/) — `Recipe`, `IngridientList`, `Instruction`.

Mobile feature sources:

- [`mobile/lib/features/recipe/`](../mobile/lib/features/recipe/) — `Recipe`, `InstractionItem`, `IngredientListItem`.
- [`mobile/lib/features/ingredient/`](../mobile/lib/features/ingredient/) — `Ingredient`.
- [`mobile/lib/features/pantry/`](../mobile/lib/features/pantry/) — `PantryItem`.
- [`mobile/lib/features/profile/`](../mobile/lib/features/profile/) — `Profile`, `Preferences`.
- [`mobile/lib/features/authentication/`](../mobile/lib/features/authentication/) — authentication flow that consumes `Profile`.

