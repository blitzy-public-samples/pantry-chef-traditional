/// Compile-time environment configuration for the PantryChef mobile client.
///
/// Values are resolved via `--dart-define` at build time; runtime mutation is
/// not supported. The single configurable value is the backend API base URL.
class EnvConfig {
  /// The PantryChef backend HTTP API root URL.
  ///
  /// Overridden at build time with `--dart-define=API_BASE_URL=<url>`. The
  /// default `http://192.168.2.20:3000/api` is a developer LAN IP; production
  /// builds MUST override this value.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api');
}
