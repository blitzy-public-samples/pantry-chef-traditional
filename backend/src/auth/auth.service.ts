import {
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import ms from 'ms';
import { JwtService } from '@nestjs/jwt';
import bcrypt from 'bcryptjs';
import { AuthEmailLoginDto } from './dto/auth-email-login.dto';
import { AuthUpdateDto } from './dto/auth-update.dto';
import { AuthRegisterLoginDto } from './dto/auth-register-login.dto';
import { NullableType } from '../utils/types/nullable.type';
import { LoginResponseType } from './types/login-response.type';
import { ConfigService } from '@nestjs/config';
import { AllConfigType } from 'src/config/config.type';
import { JwtRefreshPayloadType } from './strategies/types/jwt-refresh-payload.type';
import { JwtPayloadType } from './strategies/types/jwt-payload.type';
import { User } from 'src/users/domain/user';
import { Session } from 'src/session/domain/session';
import { UsersService } from 'src/users/users.service';
import { SessionService } from 'src/session/session.service';

/**
 * Service orchestrating authentication and session lifecycle for the auth module.
 *
 * Responsibilities:
 * - Validate email/password credentials with bcrypt.compare.
 * - Register new users via UsersService and create the initial session.
 * - Issue JWT access + refresh token pairs via JwtService.signAsync.
 * - Re-issue token pairs on refresh, gated by an existing session record.
 * - Update authenticated user profiles (oldPassword required for password changes).
 * - Soft-delete the authenticated user account and session.
 *
 * Throws HttpException (HTTP 422) on credential and validation failures and
 * UnauthorizedException on refresh when the session has been soft-deleted.
 */
@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private usersService: UsersService,
    private sessionService: SessionService,
    private configService: ConfigService<AllConfigType>,
  ) {}

  /**
   * Validate email + password credentials and issue an access + refresh token pair.
   *
   * Looks up the user by email, asserts the bcrypt hash matches the supplied
   * password, creates a new Session, and signs a token pair via getTokensData.
   *
   * @param loginDto AuthEmailLoginDto with `email` and `password`.
   * @returns Object containing { token, refreshToken, tokenExpires } (the User
   *   payload is intentionally omitted from this response shape).
   * @throws HttpException 422 if the email is not found, the user has no
   *   stored password hash, or the bcrypt comparison fails.
   */
  async validateLogin(
    loginDto: AuthEmailLoginDto,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    const user = await this.usersService.findOne({
      email: loginDto.email,
    });

    if (!user) {
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            email: 'notFound',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    if (!user.password) {
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            password: 'incorrectPassword',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    const isValidPassword = await bcrypt.compare(
      loginDto.password,
      user.password,
    );

    if (!isValidPassword) {
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            password: 'incorrectPassword',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    const session = await this.sessionService.create({
      user,
    });

    const { token, refreshToken, tokenExpires } = await this.getTokensData({
      id: user.id,
      sessionId: session.id,
    });

    return {
      refreshToken,
      token,
      tokenExpires,
    };
  }

  /**
   * Create a new user via UsersService, open a session, and issue tokens.
   *
   * Rejects if a user with the same email already exists. On success, returns
   * the same token bundle shape as validateLogin.
   *
   * @param dto AuthRegisterLoginDto with `email` and `password` (min length 6).
   * @returns Object containing { token, refreshToken, tokenExpires }.
   * @throws HttpException 422 if a user with the supplied email already exists.
   */
  async register(
    dto: AuthRegisterLoginDto,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    const existsUser = await this.usersService.findOne({
      email: dto.email,
    });

    if (existsUser) {
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            email: 'emailExists',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    const user = await this.usersService.create({
      ...dto,
      email: dto.email,
    });

    const session = await this.sessionService.create({
      user,
    });

    const { token, refreshToken, tokenExpires } = await this.getTokensData({
      id: user.id,
      sessionId: session.id,
    });

    return {
      refreshToken,
      token,
      tokenExpires,
    };
  }

  /**
   * Fetch the authenticated user record by id from the JWT payload.
   *
   * @param userJwtPayload Decoded JWT payload carrying the user `id`.
   * @returns Promise resolving to the User entity or null if not found.
   */
  async me(userJwtPayload: JwtPayloadType): Promise<NullableType<User>> {
    return this.usersService.findOne({
      id: userJwtPayload.id,
    });
  }

  /**
   * Update the authenticated user's profile.
   *
   * If `password` is being changed, `oldPassword` must also be supplied and
   * must match the user's current bcrypt hash. On a successful password
   * change, this method soft-deletes all OTHER sessions belonging to the user
   * (preserving the current session id) so that previously-issued tokens
   * are invalidated.
   *
   * @param userJwtPayload Decoded JWT payload carrying `id` and `sessionId`.
   * @param userDto AuthUpdateDto with optional firstName, lastName, password, oldPassword.
   * @returns Promise resolving to the refreshed User entity or null.
   * @throws HttpException 422 if `password` is supplied without `oldPassword`,
   *   the current user is not found, the stored password hash is missing, or
   *   bcrypt comparison fails.
   */
  async update(
    userJwtPayload: JwtPayloadType,
    userDto: AuthUpdateDto,
  ): Promise<NullableType<User>> {
    if (userDto.password) {
      if (!userDto.oldPassword) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              oldPassword: 'missingOldPassword',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }

      const currentUser = await this.usersService.findOne({
        id: userJwtPayload.id,
      });

      if (!currentUser) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              user: 'userNotFound',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }

      if (!currentUser.password) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              oldPassword: 'incorrectOldPassword',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }

      const isValidOldPassword = await bcrypt.compare(
        userDto.oldPassword,
        currentUser.password,
      );

      if (!isValidOldPassword) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              oldPassword: 'incorrectOldPassword',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      } else {
        await this.sessionService.softDelete({
          user: {
            id: currentUser.id,
          },
          excludeId: userJwtPayload.sessionId,
        });
      }
    }

    await this.usersService.update(userJwtPayload.id, userDto);

    return this.usersService.findOne({
      id: userJwtPayload.id,
    });
  }

  /**
   * Re-issue a new access + refresh token pair for the given session id.
   *
   * Looks up the session by id; if it has been soft-deleted (or never existed),
   * throws UnauthorizedException. Otherwise re-signs a fresh token pair via
   * getTokensData using the session's user id.
   *
   * @param data Object containing the `sessionId` claim from the refresh JWT payload.
   * @returns Object containing { token, refreshToken, tokenExpires }.
   * @throws UnauthorizedException if the session is missing or soft-deleted.
   */
  async refreshToken(
    data: Pick<JwtRefreshPayloadType, 'sessionId'>,
  ): Promise<Omit<LoginResponseType, 'user'>> {
    const session = await this.sessionService.findOne({
      id: data.sessionId,
    });

    if (!session) {
      throw new UnauthorizedException();
    }

    const { token, refreshToken, tokenExpires } = await this.getTokensData({
      id: session.user.id,
      sessionId: session.id,
    });

    return {
      token,
      refreshToken,
      tokenExpires,
    };
  }

  /**
   * Delete the user account by delegating to UsersService.softDelete.
   *
   * Despite the method name, UsersService.softDelete calls deleteOne and
   * PHYSICALLY removes the user document — no `deletedAt` timestamp is set.
   * Session documents are not cascaded or removed, and the DELETE /me handler
   * does not invoke logout. See the users module README § Known Limitations.
   *
   * @param user The authenticated User entity.
   * @returns Promise<void>.
   */
  async softDelete(user: User): Promise<void> {
    await this.usersService.softDelete(user.id);
  }

  /**
   * Invalidate a session by id via SessionService.softDelete.
   *
   * Subsequent refreshToken calls carrying the same `sessionId` will fail with
   * UnauthorizedException because the soft-deleted session no longer matches
   * the `findOne` lookup.
   *
   * @param data Object containing the `sessionId` claim from the JWT payload.
   * @returns Promise resolving when the session has been soft-deleted.
   */
  async logout(data: Pick<JwtRefreshPayloadType, 'sessionId'>) {
    return this.sessionService.softDelete({
      id: data.sessionId,
    });
  }

  /**
   * Sign and return a JWT access + refresh token pair plus an absolute
   * expiry timestamp for the access token.
   *
   * The access token carries `{ id, sessionId }` signed with `auth.secret`
   * and `auth.expires` TTL. The refresh token carries `{ sessionId }` signed
   * with `auth.refreshSecret` and `auth.refreshExpires` TTL — see
   * backend/env_example:L20-L23 for the default values and the module README
   * § Configuration for the env var table.
   *
   * @param data Object with `id` (User id) and `sessionId` (Session id).
   * @returns Object containing { token, refreshToken, tokenExpires } where
   *   `tokenExpires` is an absolute Unix epoch milliseconds timestamp.
   */
  private async getTokensData(data: {
    id: User['id'];
    sessionId: Session['id'];
  }) {
    const tokenExpiresIn = this.configService.getOrThrow('auth').expires;

    const tokenExpires: number = (Date.now() +
      ms(tokenExpiresIn)) as unknown as number;

    const [token, refreshToken] = await Promise.all([
      await this.jwtService.signAsync(
        {
          id: data.id,
          sessionId: data.sessionId,
        },
        {
          secret: this.configService.getOrThrow('auth').secret,
          expiresIn: tokenExpiresIn,
        },
      ),
      await this.jwtService.signAsync(
        {
          sessionId: data.sessionId,
        },
        {
          secret: this.configService.getOrThrow('auth').refreshSecret,
          expiresIn: this.configService.getOrThrow('auth').refreshExpires,
        },
      ),
    ]);

    return {
      token,
      refreshToken,
      tokenExpires,
    };
  }
}
