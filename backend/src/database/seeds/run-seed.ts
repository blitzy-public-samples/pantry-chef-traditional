import { NestFactory } from '@nestjs/core';
import { UserSeedService } from './user/user-seed.service';
// NOTE: 'IngridientSeedService' and 'PantrySeedService' (which seeds PantryIngridient documents)
// NOTE: spellings preserved verbatim across the backend codebase. Do not rename.
import { IngridientSeedService } from './ingridient/ingridient-seed.service';

import { SeedModule } from './seed.module';
import { RecipeSeedService } from './recipe/recipe-seed.service';
import { PantrySeedService } from './pantry/pantry-seed.service';

// TODO(prod): Gate this script behind an explicit --force-reseed flag or
// TODO(prod): NODE_ENV !== 'production' guard before production deployment.
/**
 * Seed runner entry point.
 *
 * Bootstraps a standalone NestApplicationContext, fetches each seed service
 * from the SeedModule DI container, and invokes .run() in dependency order:
 * UserSeedService → IngridientSeedService → RecipeSeedService → PantrySeedService.
 *
 * Order matters: PantrySeedService inserts userId references to seeded users
 * and ingridient references to seeded Ingridients (spellings preserved verbatim).
 *
 * WARNING: each seed service performs dropCollection() before re-inserting.
 * Running this in production would WIPE all user data. See
 * backend/src/database/README.md § Known Limitations.
 *
 * Invoked by `npm run seed:run:document` (Source: backend/package.json:L16).
 */
const runSeed = async () => {
  const app = await NestFactory.create(SeedModule);

  // run
  await app.get(UserSeedService).run();
  await app.get(IngridientSeedService).run();
  await app.get(RecipeSeedService).run();
  await app.get(PantrySeedService).run();

  await app.close();
};

void runSeed();
