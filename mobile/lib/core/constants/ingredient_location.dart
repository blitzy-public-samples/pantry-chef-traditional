/// Central registry of the valid pantry-item storage locations.
///
/// Supplies the fixed vocabulary used to populate storage-location form
/// selectors — most visibly the location dropdown on the pantry-item edit
/// screen (`pantry_item_edit.dart`) and the ingredient-adding form
/// (`ingredient_adding_form.dart`) — and the default selection in the
/// ingredient-add BLoC, which seeds its initial value from
/// `ingredientLocation[0]`.
///
/// Backend contract: the values `'fridge'`, `'freezer'`, and `'pantry'` must
/// match the backend `PantryIngridient.location` enum exactly. The spelling
/// `PantryIngridient` (`i` before `e`) is preserved verbatim from the backend
/// schema and is not a typo. Renaming a value here (for example `'fridge'` to
/// `'refrigerator'`) would silently break the pantry data round-trip with the
/// backend. See `../../../../DATA_MODEL.md` § PantryIngridient and
/// `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L32-L33`.
///
/// Mutability caveat: this is declared without `const` or `final` at the
/// variable level (only the list literal could be `const`), so the reference is
/// technically reassignable and the list technically mutable. Consumers should
/// nonetheless treat it as immutable shared reference data — do not mutate the
/// list in place or reassign the variable.
List<String> ingredientLocation = ['fridge', 'freezer', 'pantry'];
