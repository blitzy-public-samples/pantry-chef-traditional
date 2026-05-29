import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
import { IngridientModule } from 'src/ingridient/ingridient.module';
// SECURITY(SEC-A3): Import AuthModule to bring JwtStrategy provider into DI scope so AuthGuard('jwt') resolves
import { AuthModule } from 'src/auth/auth.module';

@Module({
  imports: [IngridientModule, AuthModule],
  providers: [AiService],
  controllers: [AiController],
})
export class AiModule {}
