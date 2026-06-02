import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Request,
  Post,
  UseGuards,
  Patch,
  Delete,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AuthEmailLoginDto } from './dto/auth-email-login.dto';
import { AuthUpdateDto } from './dto/auth-update.dto';
import { AuthGuard } from '@nestjs/passport';
import { AuthRegisterLoginDto } from './dto/auth-register-login.dto';
import { LoginResponseType } from './types/login-response.type';
import { NullableType } from '../utils/types/nullable.type';
import { User } from 'src/users/domain/user';

/**
 * REST controller exposing the authentication endpoints: registration, login,
 * current-user profile read/update, token refresh, logout, and account
 * deletion. Every route delegates to the injected {@link AuthService}.
 *
 * Routes are served under the global `api` prefix as `/api/auth/*`. The
 * declared `version: '1'` is not applied because versioning is not enabled in
 * `main.ts` (there is no `app.enableVersioning()` call), so the served paths
 * carry no version segment.
 *
 * Grouped under the Swagger tag `Auth`.
 */
@ApiTags('Auth')
@Controller({
  path: 'auth',
  version: '1',
})
export class AuthController {
  // Injects the AuthService delegate that implements all auth business logic.
  constructor(private readonly service: AuthService) {}

  /**
   * Authenticates a user by email + password and returns a freshly issued
   * access/refresh token pair (the authenticated user object is omitted from
   * this response). Public route returning HTTP 200; delegates to
   * {@link AuthService.validateLogin}.
   *
   * @param loginDto The email/password credentials (`AuthEmailLoginDto`).
   * @returns A Promise of `Omit<LoginResponseType, 'user'>` carrying `token`,
   *   `refreshToken`, and `tokenExpires`.
   * @throws 422 Unprocessable Entity when the email is not found or the
   *   password is incorrect (surfaced by the service).
   */
  @Post('email/login')
  @HttpCode(HttpStatus.OK)
  public login(
    @Body() loginDto: AuthEmailLoginDto,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    return this.service.validateLogin(loginDto);
  }

  /**
   * Registers a new account for the given email/password and immediately
   * returns an issued token pair (user omitted). Public route returning
   * HTTP 200; delegates to {@link AuthService.register}.
   *
   * @param createUserDto The new-account credentials (`AuthRegisterLoginDto`).
   * @returns A Promise of `Omit<LoginResponseType, 'user'>` carrying `token`,
   *   `refreshToken`, and `tokenExpires`.
   * @throws 422 Unprocessable Entity when the email already exists.
   */
  @Post('email/register')
  @HttpCode(HttpStatus.OK)
  async register(
    @Body() createUserDto: AuthRegisterLoginDto,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    return this.service.register(createUserDto);
  }

  /**
   * Returns the currently authenticated user's profile. Guarded by
   * `AuthGuard('jwt')` (Bearer access token); returns HTTP 200 and delegates
   * to {@link AuthService.me}.
   *
   * @param request The Express request whose `user` is the decoded JWT payload
   *   populated by `JwtStrategy`.
   * @returns A Promise of `NullableType<User>`.
   */
  @ApiBearerAuth()
  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.OK)
  public me(@Request() request): Promise<NullableType<User>> {
    return this.service.me(request.user);
  }

  /**
   * Issues a new access/refresh pair for the existing session. Does not revoke
   * prior refresh JWTs: previously issued refresh tokens remain valid until
   * they expire or the session is deleted. Guarded by
   * `AuthGuard('jwt-refresh')` (Bearer refresh token, validated by
   * `JwtRefreshStrategy`); returns HTTP 200 and delegates to
   * {@link AuthService.refreshToken} with `{ sessionId }`.
   *
   * @param request The Express request whose `user.sessionId` identifies the
   *   session whose token pair is reissued.
   * @returns A Promise of `Omit<LoginResponseType, 'user'>`.
   */
  @ApiBearerAuth()
  @Post('refresh')
  @UseGuards(AuthGuard('jwt-refresh'))
  @HttpCode(HttpStatus.OK)
  public refresh(@Request() request): Promise<Omit<LoginResponseType, 'user'>> {
    return this.service.refreshToken({
      sessionId: request.user.sessionId,
    });
  }

  /**
   * Logs out the current session by removing it. Guarded by
   * `AuthGuard('jwt')`; returns HTTP 204 No Content and delegates to
   * {@link AuthService.logout} with `{ sessionId }`.
   *
   * @param request The Express request whose `user.sessionId` identifies the
   *   session to delete.
   * @returns A Promise<void>.
   */
  @ApiBearerAuth()
  @Post('logout')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.NO_CONTENT)
  public async logout(@Request() request): Promise<void> {
    await this.service.logout({
      sessionId: request.user.sessionId,
    });
  }

  /**
   * Updates the authenticated user's profile. When a new password is supplied
   * it requires the matching `oldPassword`. Guarded by `AuthGuard('jwt')`;
   * returns HTTP 200 and delegates to {@link AuthService.update}.
   *
   * @param request The authenticated principal (decoded JWT payload).
   * @param userDto The profile changes to apply (`AuthUpdateDto`).
   * @returns A Promise of `NullableType<User>`.
   */
  @ApiBearerAuth()
  @Patch('me')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.OK)
  public update(
    @Request() request,
    @Body() userDto: AuthUpdateDto,
  ): Promise<NullableType<User>> {
    return this.service.update(request.user, userDto);
  }

  /**
   * Deletes the authenticated user's account. Guarded by `AuthGuard('jwt')`;
   * returns HTTP 204 No Content and delegates to {@link AuthService.softDelete}.
   *
   * @param request The authenticated principal (decoded JWT payload).
   * @returns A Promise<void>.
   */
  @ApiBearerAuth()
  @Delete('me')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.NO_CONTENT)
  public async delete(@Request() request): Promise<void> {
    // KNOWN ISSUE: Despite the `softDelete` name, the users repository performs
    // a HARD delete (`deleteOne`); see the users module documentation.
    return this.service.softDelete(request.user);
  }
}
