import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { SessionModule } from 'src/session/session.module';
import { UsersModule } from 'src/users/users.module';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AnonymousStrategy } from './strategies/anonymous.strategy';
import { JwtRefreshStrategy } from './strategies/jwt-refresh.strategy';

/**
 * NestJS module that wires the authentication feature. Imports `UsersModule` and
 * `SessionModule` for account and session data, enables `PassportModule` for Passport
 * integration, and registers `JwtModule` for JWT signing and verification. Exposes
 * `AuthController` and provides `AuthService` together with the `jwt`, `jwt-refresh`, and
 * `anonymous` Passport strategies.
 *
 * `JwtModule.register({})` supplies an empty default configuration because signing options
 * (secret and expiry) are passed per-call in `AuthService.getTokensData`.
 */
@Module({
  imports: [
    UsersModule,
    SessionModule,
    PassportModule,
    // MailModule,
    JwtModule.register({}),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, JwtRefreshStrategy, AnonymousStrategy],
})
export class AuthModule {}
