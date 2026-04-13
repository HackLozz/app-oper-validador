import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/app_config.dart';
import '../../../core/result.dart';
import '../domain/validation_response.dart';

class ValidationApiClient {
  ValidationApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Result<ValidationResponse>> healthCheck(String baseUrl) async {
    final uri = _buildUri(baseUrl, '/health');
    if (uri == null) {
      return const Failure('URL inválida. Verifica el formato (https://mi-api.com).');
    }

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(milliseconds: AppConfig.timeoutMs));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(
          ValidationResponse.fallback(
            response.statusCode,
            'Conexión exitosa con el API.',
          ),
        );
      }

      return Success(
        ValidationResponse.fallback(
          response.statusCode,
          'API respondió con código ${response.statusCode}.',
        ),
      );
    } catch (error) {
      return Failure('No fue posible conectar con el API: $error');
    }
  }

  Future<Result<ValidationResponse>> validateDocument({
    required String baseUrl,
    required String document,
  }) async {
    final uri = _buildUri(baseUrl, AppConfig.validationEndpoint);
    if (uri == null) {
      return const Failure('URL inválida. Verifica el formato (https://mi-api.com).');
    }

    try {
      final payload = {'document': document};
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(milliseconds: AppConfig.timeoutMs));

      final data = _decodeJsonMap(response.body);
      if (data != null) {
        return Success(ValidationResponse.fromJson(data, response.statusCode));
      }

      return Success(
        ValidationResponse.fallback(
          response.statusCode,
          'Respuesta no JSON recibida desde el API.',
        ),
      );
    } catch (error) {
      return Failure('Falló la validación remota: $error');
    }
  }

  Uri? _buildUri(String baseUrl, String endpoint) {
    final sanitizedBaseUrl = baseUrl.trim();
    if (sanitizedBaseUrl.isEmpty) return null;

    final parsed = Uri.tryParse(sanitizedBaseUrl);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) return null;

    final normalizedPath = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return parsed.replace(path: normalizedPath);
  }

  Map<String, dynamic>? _decodeJsonMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
