import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

/// Immutable, JSON-serializable user-preferences value object.
///
/// Captures dietary choices, allergies, disliked ingredients, and an
/// optional preferred cooking time. JSON conversion is handled by
/// generated helpers in the `preferences.g.dart` part file.
@JsonSerializable()
class Preferences {
  /// Dietary choices; defaults to an empty list.
  final List<String> dietary;
  /// Known allergies; defaults to an empty list.
  final List<String> allergies;
  /// Disliked ingredients; defaults to an empty list.
  final List<String> dislikedIngredients;
  /// Optional preferred cooking time.
  final double? cookingTime;

  const Preferences({
    this.dietary = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
    this.cookingTime,
  });

  /// Creates a [Preferences] from a decoded JSON [json] map.
  factory Preferences.fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);

  /// Converts this [Preferences] to its JSON map representation.
  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}
