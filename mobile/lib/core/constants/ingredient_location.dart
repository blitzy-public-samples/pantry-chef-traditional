/// Shared vocabulary of ingredient storage categories used across the app.
///
/// Consumed by ingredient/pantry forms, select-field selectors, and
/// value-selection logic to populate and validate the storage `location`
/// of an ingredient. Its values are `['fridge', 'freezer', 'pantry']`.
///
// Declared as a plain `List<String>` (not `const`/`final`), so it is
// technically a mutable shared reference; callers should treat it as
// read-only reference data.
List<String> ingredientLocation = ['fridge', 'freezer', 'pantry'];
