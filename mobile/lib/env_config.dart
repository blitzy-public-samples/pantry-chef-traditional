/// Centralized, compile-time environment configuration holder for the
/// mobile client. Serves as the canonical source of truth for the backend
/// API root URL consumed by the networking layer and repository code.
///
class EnvConfig {
  /// API root URL resolved at COMPILE TIME via
  /// `String.fromEnvironment('API_BASE_URL', ...)`, so it is fixed per build
  /// and is NOT runtime-mutable.
  ///
  /// Default value `http://192.168.2.20:3000/api` is a LAN IP that already
  /// includes the `/api` prefix; the backend serves routes under `/api` with
  /// no `/v1/` segment.
  ///
  /// Override at build/run time with:
  /// `--dart-define API_BASE_URL=http://<host>:3000/api`.
  ///
  /// `Endpoints.apiBaseUrl` re-exports this value for the Dio client.
  /// Source: mobile/lib/core/constants/endpoints.dart:L19
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api');
}
