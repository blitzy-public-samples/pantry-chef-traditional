import 'package:json_annotation/json_annotation.dart';

part 'auth.dto.g.dart';

@JsonSerializable()
class AuthDto {
  final String email;
  final String password;

  const AuthDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$AuthDtoToJson(this);
}
