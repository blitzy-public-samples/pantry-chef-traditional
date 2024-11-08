import 'dart:convert';

import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/profile/domain/models/preferences.dart';

class Mappers {
  Mappers._();

  static Map<String, dynamic> categoryToJson(Category item) => item.toJson();

  static Map<String, dynamic> unitToJson(Unit item) => item.toJson();

  static String? orderToJson(List<OrderDto>? item) =>
      item != null ? json.encode(item.map((el) => el.toJson()).toList()) : null;

  static Map<String, dynamic> preferencesToJson(Preferences item) => item.toJson();
}
