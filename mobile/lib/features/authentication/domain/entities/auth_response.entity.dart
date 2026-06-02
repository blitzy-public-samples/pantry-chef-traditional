import 'package:json_annotation/json_annotation.dart';

part 'auth_response.entity.g.dart';

/// Immutable token-response value object returned by the login and
/// signup flows.
///
/// Holds the issued access [token] and [refreshToken]. Annotated with
/// `@JsonSerializable()` and deserialized from backend JSON via the
/// generated helper.
@JsonSerializable()
class AuthResponse {
  /// Access (JWT) token used to authorize API requests.
  final String token;
  /// Refresh token used to obtain a new access token.
  final String refreshToken;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
  });

  /// Creates an [AuthResponse] from a decoded JSON map [json].
  ///
  /// Delegates to the generated `_$AuthResponseFromJson` helper.
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}
