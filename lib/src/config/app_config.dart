class AppConfig {
  AppConfig._();

  static const defaultApiBaseUrl = String.fromEnvironment(
    'VALIDATION_API_BASE_URL',
    defaultValue: '',
  );

  static const validationEndpoint = String.fromEnvironment(
    'VALIDATION_API_ENDPOINT',
    defaultValue: '/api/v1/validation/check',
  );

  static const timeoutMs = int.fromEnvironment(
    'VALIDATION_API_TIMEOUT_MS',
    defaultValue: 8000,
  );
}
