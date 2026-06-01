// Barrel export for the pantry feature's data-transfer objects.
//
// Re-exports [CreatePantryItemDto] and [UpdatePantryItemDto] so consumers
// can import both DTOs via a single statement:
//
// ```dart
// import 'package:pantry_chef/features/pantry/data/dto/index.dart';
// ```
//
// Consumed by [PantryApi] at `mobile/lib/features/pantry/data/api/pantry.api.dart`
// (verified: line 5 imports this barrel).
export './create_pantry_item.dto.dart';
export './update_pantry_item.dto.dart';
