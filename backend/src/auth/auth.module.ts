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
 * NestJS module wiring the Auth feature.
 *
 * Imports UsersModule and SessionModule for user lookup and session
 * lifecycle, PassportModule for the Passport strategy framework, and
 * JwtModule.register({}) for token signing/verification (per-call options
 * are passed at sign time, not at module registration).
 *
 * Registers AuthController as the HTTP entry point and provides AuthService
 * plus three Passport strategies: JwtStrategy (access tokens),
 * JwtRefreshStrategy (refresh tokens), and AnonymousStrategy (unauthenticated
 * routes such as /email/login and /email/register).
 *
 * The MailModule import is commented out (line 17) because password reset
 * endpoints are not wired — see README § Known Limitations and
 * ../../../PRODUCTION_READINESS.md § Security Hardening for the documented gap.
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
