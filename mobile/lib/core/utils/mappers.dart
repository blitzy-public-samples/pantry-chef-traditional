import 'dart:convert';

import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

/// Non-instantiable static namespace of model-to-JSON serialization
/// helpers.
///
/// The private constructor `Mappers._()` prevents instantiation.
///
/// Source: mobile/lib/core/utils/mappers.dart:L8-L9
class Mappers {
  Mappers._();

  /// Serializes [item] by delegating to `Category.toJson()`.
  ///
  /// Source: mobile/lib/core/utils/mappers.dart:L11
  static Map<String, dynamic> categoryToJson(Category item) => item.toJson();

  /// Serializes [item] by delegating to `Unit.toJson()`.
  ///
  /// Source: mobile/lib/core/utils/mappers.dart:L13
  static Map<String, dynamic> unitToJson(Unit item) => item.toJson();

  /// Null-safe serializer: returns `null` when [item] is null,
  /// otherwise maps each `OrderDto` to JSON and `json.encode`s the
  /// resulting list into a String.
  ///
  /// Source: mobile/lib/core/utils/mappers.dart:L15-L16
  static String? orderToJson(List<OrderDto>? item) =>
      item != null ? json.encode(item.map((el) => el.toJson()).toList()) : null;

  /// Serializes [item] by delegating to `Preferences.toJson()`.
  ///
  /// Source: mobile/lib/core/utils/mappers.dart:L18
  static Map<String, dynamic> preferencesToJson(Preferences item) => item.toJson();
}
