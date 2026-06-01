import 'package:json_annotation/json_annotation.dart';

part 'auth.dto.g.dart';

/// Request DTO carrying email + password for both login and signup calls.
///
/// A single DTO drives both /auth/email/login and /auth/email/register; the same shape is
/// reused server-side. json_serializable generates the toJson companion in auth.dto.g.dart
/// (auto-generated, excluded from DartDoc scope per AAP §0.8.2).
@JsonSerializable()
class AuthDto {
  /// User-provided email; validated by RegExps.email in AuthBloc before submission.
  final String email;
  /// User-provided plaintext password; transported over TLS, hashed server-side via bcryptjs.
  final String password;

  /// Creates an immutable DTO with the required email and password fields.
  const AuthDto({
    required this.email,
    required this.password,
  });

  /// Serializes this DTO to a JSON-compatible Map via json_serializable codegen.
  Map<String, dynamic> toJson() => _$AuthDtoToJson(this);
}
