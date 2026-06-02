// ignore_for_file: dangling_library_doc_comments
/// Barrel file for the profile feature's domain use cases.
///
/// Re-exports the profile use cases as a single, stable import surface
/// so consumers can import one path instead of each use case file.
///
/// Re-exports ONLY `get_profile.usecase.dart` and `logout.usecase.dart`.
/// `favorite_recipes_update.usecase.dart` is intentionally NOT part of
/// this barrel and is imported directly by its consumers.
export './get_profile.usecase.dart';
export './logout.usecase.dart';
