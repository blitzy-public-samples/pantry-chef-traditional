class EnvConfig {
  // QA FINAL Issue #1: the backend now enables URI versioning (every controller
  // declares `version: '1'`), so all endpoints resolve under `/api/v1/*`. The
  // client base URL therefore includes the `/v1` segment so the existing
  // endpoint paths (auth, recipe, pantry, ingredient, ai, and the new
  // `/recipe/suggestions`) reach the versioned routes end-to-end.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api/v1');
}
