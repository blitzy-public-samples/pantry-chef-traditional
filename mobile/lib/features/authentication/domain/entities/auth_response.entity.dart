import 'package:json_annotation/json_annotation.dart';

part 'auth_response.entity.g.dart';

@JsonSerializable()
class AuthResponse {
  final String token;
  final String refreshToken;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}
