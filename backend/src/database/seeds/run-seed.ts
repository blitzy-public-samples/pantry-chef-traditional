import { NestFactory } from '@nestjs/core';
import { UserSeedService } from './user/user-seed.service';
import { IngridientSeedService } from './ingridient/ingridient-seed.service';

import { SeedModule } from './seed.module';
import { RecipeSeedService } from './recipe/recipe-seed.service';
import { PantrySeedService } from './pantry/pantry-seed.service';

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
