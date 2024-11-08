import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

@JsonSerializable()
class Preferences {
  final List<String> dietary;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final double? cookingTime;

  const Preferences({
    this.dietary = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
    this.cookingTime,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}
