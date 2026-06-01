import 'dart:convert';

import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

/// Non-instantiable static namespace for cross-feature JSON serialization
/// helpers; the private `Mappers._()` constructor enforces non-instantiability.
///
/// Used as `@JsonKey(toJson: Mappers.<fn>)` annotations on DTO fields where the
/// default `json_serializable` output is insufficient. For example,
/// `SearchDto.sort` (a `List<OrderDto>?`) uses `Mappers.orderToJson` to
/// serialize as a JSON string for a URL query parameter — see
/// `mobile/lib/core/data/dto/search.dto.dart`.
class Mappers {
  Mappers._();

  /// Serializes a [Category] model to JSON by delegating to its own `toJson()`.
  ///
  /// Exists so DTO files can reference `Mappers.categoryToJson` via
  /// `@JsonKey(toJson: ...)` without importing the feature-specific [Category]
  /// model directly — preserving the boundary between `core/data/dto/` and
  /// `features/ingredient/`.
  static Map<String, dynamic> categoryToJson(Category item) => item.toJson();

  /// Serializes a [Unit] model to JSON by delegating to its own `toJson()`.
  ///
  /// Analogous to [categoryToJson] — exists to keep DTO files free of the
  /// feature-specific [Unit] model import.
  static Map<String, dynamic> unitToJson(Unit item) => item.toJson();

  /// Serializes a list of [OrderDto] into a JSON STRING (not a list or map)
  /// suitable for embedding in a URL query parameter.
  ///
  /// Null-guards the input (returns `null` when [item] is `null`, so
  /// `@JsonKey` omits the field entirely), maps each [OrderDto] to its JSON map
  /// via `.toJson()`, then encodes the resulting list as a JSON string with
  /// `dart:convert`'s `json.encode`.
  ///
  /// Consumed by `SearchDto.sort` via `@JsonKey(toJson: Mappers.orderToJson)`
  /// at `mobile/lib/core/data/dto/search.dto.dart`; the backend's `sort` query
  /// argument expects a JSON-encoded array as a single string value.
  static String? orderToJson(List<OrderDto>? item) =>
      item != null ? json.encode(item.map((el) => el.toJson()).toList()) : null;

  /// Serializes a [Preferences] model to JSON by delegating to its own
  /// `toJson()`.
  ///
  /// Disambiguation: [Preferences] here is the user's dietary preferences model
  /// from `mobile/lib/features/profile/domain/models/preferences.dart`, NOT the
  /// `Preferences` storage-key namespace at
  /// `mobile/lib/core/constants/preferences.dart` (which holds the
  /// `shared_preferences` key strings). Both share the class name but differ by
  /// import path.
  static Map<String, dynamic> preferencesToJson(Preferences item) => item.toJson();
}
