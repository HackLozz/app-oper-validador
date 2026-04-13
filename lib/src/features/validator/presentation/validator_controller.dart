import 'package:flutter/foundation.dart';

import '../../../config/app_config.dart';
import '../../../core/result.dart';
import '../data/local_settings_repository.dart';
import '../data/validation_api_client.dart';
import '../domain/validation_response.dart';

class ValidatorController extends ChangeNotifier {
  ValidatorController({
    required LocalSettingsRepository settingsRepository,
    required ValidationApiClient apiClient,
  })  : _settingsRepository = settingsRepository,
        _apiClient = apiClient;

  final LocalSettingsRepository _settingsRepository;
  final ValidationApiClient _apiClient;

  bool _isLoading = false;
  String _statusMessage = 'Configura la URL y prueba la conexión.';
  String _apiBaseUrl = AppConfig.defaultApiBaseUrl;

  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  String get apiBaseUrl => _apiBaseUrl;

  Future<void> initialize() async {
    final stored = await _settingsRepository.getApiBaseUrl();
    if (stored != null && stored.trim().isNotEmpty) {
      _apiBaseUrl = stored;
      _statusMessage = 'URL cargada desde almacenamiento local.';
      notifyListeners();
      return;
    }

    if (_apiBaseUrl.isNotEmpty) {
      _statusMessage = 'URL cargada desde --dart-define.';
      notifyListeners();
    }
  }

  Future<void> saveBaseUrl(String value) async {
    final normalized = value.trim();
    await _settingsRepository.saveApiBaseUrl(normalized);
    _apiBaseUrl = normalized;
    _statusMessage = 'URL guardada correctamente.';
    notifyListeners();
  }

  Future<void> runHealthCheck() async {
    await _performRequest(() => _apiClient.healthCheck(_apiBaseUrl));
  }

  Future<void> validateDocument(String document) async {
    final normalized = document.trim();
    if (normalized.isEmpty) {
      _statusMessage = 'Ingresa un documento antes de validar.';
      notifyListeners();
      return;
    }

    await _performRequest(
      () => _apiClient.validateDocument(
        baseUrl: _apiBaseUrl,
        document: normalized,
      ),
    );
  }

  Future<void> _performRequest(
    Future<Result<ValidationResponse>> Function() callback,
  ) async {
    if (_apiBaseUrl.trim().isEmpty) {
      _statusMessage = 'Debes configurar primero una URL base.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await callback();
    _statusMessage = result.when(
      success: (response) =>
          '${response.message} (HTTP ${response.statusCode}, allowed=${response.allowed})',
      failure: (error) => error,
    );

    _isLoading = false;
    notifyListeners();
  }
}
