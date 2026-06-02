import 'package:json_annotation/json_annotation.dart';

part 'auth.dto.g.dart';

/// Request payload DTO carrying user credentials for the auth endpoints.
///
/// Holds the email + password submitted during login and registration
/// (signup), serialized to JSON for the `POST` calls issued by
/// `AuthenticationApi.login` and `AuthenticationApi.signup`.
///
/// This is a `@JsonSerializable()` request-only (serialize-only) DTO: it
/// exposes `toJson()` and intentionally declares no `fromJson` factory.
@JsonSerializable()
class AuthDto {
  /// User email address used as the login identifier.
  final String email;
  /// User plaintext password sent to the auth endpoint.
  final String password;

  const AuthDto({
    required this.email,
    required this.password,
  });

  /// Serializes this DTO to a JSON map via the generated
  /// `_$AuthDtoToJson` helper (defined in the `auth.dto.g.dart` part,
  /// which is out of scope for documentation).
  Map<String, dynamic> toJson() => _$AuthDtoToJson(this);
}
