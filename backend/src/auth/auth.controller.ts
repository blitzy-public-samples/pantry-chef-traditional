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
 * Controller routing /api/v1/auth/* requests to AuthService.
 *
 * Six endpoints are guarded by AuthGuard('jwt') or AuthGuard('jwt-refresh');
 * /email/login and /email/register accept unauthenticated requests via
 * the anonymous strategy. The controller is tagged for Swagger as 'Auth'.
 *
 * Password reset DTOs (AuthForgotPasswordDto, AuthResetPasswordDto) exist
 * under ./dto/ but no corresponding endpoints are wired — see the module
 * README § Known Limitations for the documented gap.
 */
@ApiTags('Auth')
@Controller({
  path: 'auth',
  version: '1',
})
export class AuthController {
  constructor(private readonly service: AuthService) {}

  /**
   * POST /api/v1/auth/email/login — email + password login.
   *
   * Anonymous endpoint; no guard. Returns the access + refresh token pair
   * plus a token expiry timestamp. The authenticated user payload is fetched
   * separately via GET /me.
   *
   * @param loginDto Validated AuthEmailLoginDto with `email` and `password`.
   * @returns Promise resolving to { token, refreshToken, tokenExpires }.
   * @throws HttpException 422 if the user is not found or the password is incorrect.
   */
  @Post('email/login')
  @HttpCode(HttpStatus.OK)
  public login(
    @Body() loginDto: AuthEmailLoginDto,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    return this.service.validateLogin(loginDto);
  }

  /**
   * POST /api/v1/auth/email/register — email + password registration.
   *
   * Anonymous endpoint; no guard. Creates a new user via UsersService and
   * issues an initial access + refresh token pair.
   *
   * @param createUserDto Validated AuthRegisterLoginDto with `email` and `password`.
   * @returns Promise resolving to { token, refreshToken, tokenExpires }.
   * @throws HttpException 422 if a user with the given email already exists.
   */
  @Post('email/register')
  @HttpCode(HttpStatus.OK)
  async register(
    @Body() createUserDto: AuthRegisterLoginDto,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    return this.service.register(createUserDto);
  }

  /**
   * GET /api/v1/auth/me — return the currently authenticated user.
   *
   * Requires a valid access token via AuthGuard('jwt'). The JWT payload's
   * `id` is used to fetch the latest user record from UsersService.
   *
   * @param request Authenticated Express request; `request.user` is populated by JwtStrategy.
   * @returns Promise resolving to the User entity or null if not found.
   */
  @ApiBearerAuth()
  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.OK)
  public me(@Request() request): Promise<NullableType<User>> {
    return this.service.me(request.user);
  }

  /**
   * POST /api/v1/auth/refresh — re-issue access + refresh tokens.
   *
   * Requires a valid refresh token via AuthGuard('jwt-refresh'). The refresh
   * token must carry a `sessionId` claim and the corresponding session must
   * still exist (i.e., not soft-deleted).
   *
   * @param request Authenticated Express request; `request.user` is populated by
   *   JwtRefreshStrategy.
   * @returns Promise resolving to a new { token, refreshToken, tokenExpires } pair.
   * @throws UnauthorizedException if the session is missing or soft-deleted.
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
   * POST /api/v1/auth/logout — invalidate the current session.
   *
   * Requires a valid access token via AuthGuard('jwt'). Soft-deletes the
   * session identified by `request.user.sessionId`, preventing subsequent
   * refresh-token rotations from succeeding for that session.
   *
   * @param request Authenticated Express request with `sessionId` on `request.user`.
   * @returns Promise<void>; responds with HTTP 204 No Content.
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
   * PATCH /api/v1/auth/me — update the authenticated user's profile.
   *
   * Requires a valid access token via AuthGuard('jwt'). If `password` is
   * being changed, `oldPassword` must also be supplied and must match the
   * current bcrypt hash (see AuthService.update for the verification flow).
   *
   * @param request Authenticated Express request; `request.user` carries the JWT payload.
   * @param userDto Validated AuthUpdateDto with optional firstName, lastName, password,
   *   oldPassword.
   * @returns Promise resolving to the refreshed User entity or null.
   * @throws HttpException 422 if `password` is supplied without a matching `oldPassword`.
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
   * DELETE /api/v1/auth/me — soft-delete the authenticated user account.
   *
   * Requires a valid access token via AuthGuard('jwt'). Delegates to
   * UsersService.softDelete, which sets the `deletedAt` timestamp on the
   * user document per the soft-delete contract documented in DATA_MODEL.md.
   *
   * @param request Authenticated Express request; `request.user` carries the JWT payload.
   * @returns Promise<void>; responds with HTTP 204 No Content.
   */
  @ApiBearerAuth()
  @Delete('me')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.NO_CONTENT)
  public async delete(@Request() request): Promise<void> {
    return this.service.softDelete(request.user);
  }
}
