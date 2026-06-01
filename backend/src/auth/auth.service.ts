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
 * Orchestrates authentication business logic for the application.
 *
 * Coordinates credential validation, access/refresh token issuance and
 * rotation, session creation and revocation, profile updates, and account
 * deletion by delegating to the JWT, users, session, and configuration
 * collaborators it receives via constructor injection.
 */
@Injectable()
export class AuthService {
  // Injects JwtService, UsersService, SessionService, and ConfigService.
  constructor(
    private jwtService: JwtService,
    private usersService: UsersService,
    private sessionService: SessionService,
    private configService: ConfigService<AllConfigType>,
  ) {}

  /**
   * Validates email/password credentials and, on success, creates a session
   * and issues an access/refresh token pair.
   *
   * @param loginDto - The submitted email/password credentials.
   * @returns A promise resolving to the issued token pair payload
   *   (`Omit<LoginResponseType, 'user'>`): token, refreshToken, tokenExpires.
   * @throws HttpException 422 Unprocessable Entity when the user is not found,
   *   has no password set, or the supplied password does not match.
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

    // Compare the plaintext password against the stored bcrypt hash.
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

    // Persist a new session that backs the issued refresh token.
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
   * Registers a new user, rejecting duplicate emails, then creates a session
   * and issues an access/refresh token pair.
   *
   * @param dto - The registration payload (`AuthRegisterLoginDto`).
   * @returns A promise resolving to the issued token pair payload
   *   (`Omit<LoginResponseType, 'user'>`): token, refreshToken, tokenExpires.
   * @throws HttpException 422 Unprocessable Entity when a user already exists
   *   with the supplied email.
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
   * Loads the user referenced by a decoded access-token payload.
   *
   * @param userJwtPayload - The decoded JWT payload (`JwtPayloadType`) whose
   *   `id` identifies the user to load.
   * @returns A promise resolving to the matching `NullableType<User>`.
   */
  async me(userJwtPayload: JwtPayloadType): Promise<NullableType<User>> {
    return this.usersService.findOne({
      id: userJwtPayload.id,
    });
  }

  /**
   * Updates the authenticated user's profile. When the password is changed,
   * verifies `oldPassword` and revokes the user's other sessions.
   *
   * @param userJwtPayload - The authenticated principal (`JwtPayloadType`).
   * @param userDto - The profile changes to apply (`AuthUpdateDto`).
   * @returns A promise resolving to the reloaded `NullableType<User>`.
   * @throws HttpException 422 Unprocessable Entity when `password` is supplied
   *   without `oldPassword`, when the current user or stored password is
   *   missing, or when `oldPassword` is incorrect.
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

      // Verify the supplied old password before allowing a password change.
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
        // Revoke all other sessions, keeping the current one (excludeId).
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
   * Issues a rotated access/refresh token pair for an existing session.
   *
   * @param data - An object carrying the `sessionId` to refresh
   *   (`Pick<JwtRefreshPayloadType, 'sessionId'>`).
   * @returns A promise resolving to the rotated token pair payload
   *   (`Omit<LoginResponseType, 'user'>`): token, refreshToken, tokenExpires.
   * @throws UnauthorizedException when the referenced session does not exist.
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
   * Deletes the given user's account via the users service.
   *
   * @param user - The user whose account is removed.
   * @returns A promise that resolves once the deletion completes.
   */
  async softDelete(user: User): Promise<void> {
    // KNOWN ISSUE: Despite the name, UsersService.softDelete ultimately
    // performs a HARD delete in the users repository (Mongoose `deleteOne`).
    await this.usersService.softDelete(user.id);
  }

  /**
   * Logs out a session by deleting it.
   *
   * @param data - An object carrying the `sessionId` of the session to end
   *   (`Pick<JwtRefreshPayloadType, 'sessionId'>`).
   * @returns The result of `SessionService.softDelete({ id })`.
   */
  async logout(data: Pick<JwtRefreshPayloadType, 'sessionId'>) {
    // KNOWN ISSUE: The session repository hard-deletes via Mongoose
    // `deleteMany`, so this revokes the session rather than soft-deleting it.
    return this.sessionService.softDelete({
      id: data.sessionId,
    });
  }

  /**
   * Signs the access and refresh JWTs and computes the access-token expiry
   * timestamp. Private token factory shared by login, register, and refresh.
   */
  private async getTokensData(data: {
    id: User['id'];
    sessionId: Session['id'];
  }) {
    // Read the access-token TTL string (e.g. '15m') from auth config.
    const tokenExpiresIn = this.configService.getOrThrow('auth').expires;

    // Convert the TTL to ms and add to now() to get the absolute expiry
    // (epoch ms).
    const tokenExpires: number = (Date.now() +
      ms(tokenExpiresIn)) as unknown as number;

    const [token, refreshToken] = await Promise.all([
      // Access token: signed with auth.secret, expires in auth.expires (15m default)
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
      // Refresh token: signed with auth.refreshSecret, expires in auth.refreshExpires (3650d)
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
