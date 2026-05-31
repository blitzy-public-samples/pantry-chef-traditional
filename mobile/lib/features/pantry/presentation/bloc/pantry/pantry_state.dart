part of 'pantry_bloc.dart';

/// Immutable state for [PantryBloc].
///
/// The single field [items] is nullable; a `null` value signals "not yet
/// loaded" and triggers an initial [PantryItemsFetched] dispatch in
/// [PantryMain] (Source:
/// `presentation/widgets/screens/patry_main.dart:L21-L24`). An empty
/// `List<PantryItem>` (length 0) means "loaded and empty" — different from
/// `null`.
class PantryState extends Equatable {
  /// Cached list of pantry items.
  ///
  /// `null` indicates uninitialized (not-yet-loaded) state which triggers a
  /// lazy [PantryItemsFetched] dispatch from [PantryMain]. An empty
  /// `List<PantryItem>` (length 0) means "loaded and empty" — different
  /// from `null`. Each element is a [PantryItem] whose `ingridient` field
  /// (spelling preserved verbatim from backend) carries the nested
  /// ingredient details.
  final List<PantryItem>? items;

  /// Const constructor.
  ///
  /// Defaults [items] to `null` (uninitialized) so the first build of
  /// [PantryMain] dispatches [PantryItemsFetched] before rendering content.
  const PantryState({
    this.items,
  });

  @override
  List<Object?> get props => [items];

  /// Immutable-update helper.
  ///
  /// Pass `items: someList` to set the new list; omitting `items` (or
  /// passing `null`) preserves the current `this.items` via the
  /// `items ?? this.items` fallback at L17. **Note**: this implementation
  /// does NOT support resetting `items` back to `null` from a non-null
  /// state — the `??` operator falls through. To wipe the list, dispatch
  /// [PantryListReseted] which constructs a fresh `PantryState()` instead.
  PantryState copyWith({
    final List<PantryItem>? items,
  }) =>
      PantryState(
        items: items ?? this.items,
      );
}
