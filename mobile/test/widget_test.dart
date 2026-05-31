// Smoke test for the PantryChef application shell.
//
// This file replaces the original `flutter create` "Counter increments smoke
// test" scaffold, which asserted a non-existent counter widget and had been
// failing since the init commit (it was never updated when the project replaced
// the generated counter app with the real PantryChef `App`). Rather than
// testing a counter that does not exist, this boots the real `App` and verifies
// that the application shell renders without crashing.
//
// `App` requires the same bootstrap that `main.dart` performs before
// `runApp(const App())`: the GetIt service locator (the `_AppState` field
// initializer resolves `SharedPreferencesHelper`), a SharedPreferences backing
// store, and a `HydratedBloc` storage backend (`ProfileBloc` is registered with
// `lazy: false` and calls `hydrate()` in its constructor). No mocking package is
// used — a hand-written in-memory `Storage` keeps the test dependency-free,
// matching the repository's test-tooling rule.

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/core/presentation/widgets/app.dart';
import 'package:pantry_chef/core/utils/service_locator.dart';
import 'package:pantry_chef/features/authentication/presentation/widgets/screens/authentication_start.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal in-memory [Storage] so `ProfileBloc.hydrate()` works under test
/// without the real `path_provider`-backed `HydratedStorage`.
class _InMemoryHydratedStorage implements Storage {
  final Map<String, dynamic> _store = <String, dynamic>{};

  @override
  dynamic read(String key) => _store[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Start from a clean locator so repeated runs do not collide on the
    // singleton registrations performed by setupLocator().
    await getIt.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    HydratedBloc.storage = _InMemoryHydratedStorage();
    await setupLocator();
  });

  testWidgets('App boots and renders the unauthenticated start screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Let the localization delegates and the auth-start scaffold settle.
    await tester.pumpAndSettle();

    // The mocked SharedPreferences has no access token, so the app shows the
    // AuthenticationStart screen rather than the authenticated Home shell.
    expect(find.byType(App), findsOneWidget);
    expect(find.byType(AuthenticationStart), findsOneWidget);
  });
}
