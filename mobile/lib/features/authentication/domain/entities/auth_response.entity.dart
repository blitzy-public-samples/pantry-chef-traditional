import 'package:json_annotation/json_annotation.dart';

part 'auth_response.entity.g.dart';

/// JSON-serializable response payload returned by /auth/email/login and /auth/email/register.
///
/// Carries the freshly issued JWT access token and refresh token. The mobile client persists
/// both via SharedPreferencesHelper after a successful authentication call.
@JsonSerializable()
class AuthResponse {
  /// Short-lived JWT access token used as a Bearer credential on subsequent API calls.
  final String token;

  /// Long-lived refresh token used by DioClient to obtain a new access token on 401/419.
  final String refreshToken;

  /// Creates an immutable response payload with the given access and refresh tokens.
  const AuthResponse({
    required this.token,
    required this.refreshToken,
  });

  /// Deserializes the backend JSON payload into an AuthResponse via json_serializable codegen.
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}
