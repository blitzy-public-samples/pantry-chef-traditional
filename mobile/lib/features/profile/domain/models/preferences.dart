import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

/// Client-side value object mirroring the embedded `Preferences` subdocument
/// in the backend `User` schema.
///
/// Captures the user's dietary tags ([dietary]), allergy list ([allergies]),
/// disliked ingredients ([dislikedIngredients]), and an optional maximum
/// [cookingTime]. The `@JsonSerializable()` annotation generates the
/// serialization helpers in `preferences.g.dart` (a generated `part` file).
///
/// **Disambiguation:** this `Preferences` class is the user's dietary
/// preferences *model*. It is distinct from the `Preferences` *namespace* at
/// `mobile/lib/core/constants/preferences.dart`, which holds SharedPreferences
/// storage keys (`accessToken`, `refreshToken`, `preferredLanguage`). Both
/// share the identifier but live in different packages.
///
/// The constructor defaults all three list fields to `const []` (empty), so
/// callers can construct `const Preferences()` with no arguments to obtain a
/// valid empty-value sentinel.
///
/// See [../../../../DATA_MODEL.md](../../../../DATA_MODEL.md) § Preferences
/// (embedded subdocument) for the canonical field-by-field schema.
@JsonSerializable()
class Preferences {
  /// Selected dietary tags (e.g., `vegan`, `vegetarian`).
  ///
  /// Defaults to `[]` via the constructor. Consumed by the backend recipe
  /// matching pipeline as a `$all` filter against `Recipe.tags`.
  final List<String> dietary;
  /// Ingredient names (or IDs) the user is allergic to.
  ///
  /// Defaults to `[]`. Used by the backend recipe matching pre-filter as a
  /// `$nin` filter against the recipe's `ingridientList` (spelling preserved
  /// verbatim on the backend — see
  /// [../../../../DATA_MODEL.md](../../../../DATA_MODEL.md) § Recipe collection).
  final List<String> allergies;
  /// Ingredients the user dislikes (soft exclusion).
  ///
  /// Defaults to `[]`. Plays the same role as [allergies] in the recipe
  /// matching pipeline (`$nin` against the recipe's `ingridientList` — spelling
  /// preserved verbatim); the distinction is semantic and lives in the UI
  /// (allergies are hard exclusions; disliked ingredients are soft).
  final List<String> dislikedIngredients;
  /// Maximum desired cooking time, in the units defined by the backend
  /// (minutes).
  ///
  /// Used as a `$lte` filter in recipe matching. Nullable to indicate "no cap":
  /// when `null`, the backend does not constrain `Recipe.cookingTime` in the
  /// match query.
  final double? cookingTime;

  /// Creates an immutable [Preferences] value object with default empty
  /// collections.
  ///
  /// All three list fields ([dietary], [allergies], [dislikedIngredients])
  /// default to `const []`; [cookingTime] defaults to `null`. The const
  /// constructor and defaults make `const Preferences()` valid for use in
  /// `const` contexts (e.g., as a default state).
  const Preferences({
    this.dietary = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
    this.cookingTime,
  });

  /// Deserializes a [Preferences] from JSON.
  ///
  /// Delegates to `_$PreferencesFromJson` in `preferences.g.dart`.
  factory Preferences.fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);

  /// Serializes this [Preferences] to JSON.
  ///
  /// Delegates to `_$PreferencesToJson` in `preferences.g.dart`. Also invoked
  /// indirectly by `Mappers.preferencesToJson`, used as the `Profile.preferences`
  /// field's `@JsonKey(toJson: ...)` mapper.
  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}
