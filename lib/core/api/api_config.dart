/// Environment-based API configuration.
/// Override at build time with: --dart-define=BASE_URL=https://your-server.com
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
