import 'package:flutter/material.dart';

import '../data/local_settings_repository.dart';
import '../data/validation_api_client.dart';
import 'validator_controller.dart';

class ValidatorPage extends StatefulWidget {
  const ValidatorPage({super.key});

  @override
  State<ValidatorPage> createState() => _ValidatorPageState();
}

class _ValidatorPageState extends State<ValidatorPage> {
  late final ValidatorController _controller;
  late final TextEditingController _urlController;
  late final TextEditingController _documentController;

  @override
  void initState() {
    super.initState();
    _controller = ValidatorController(
      settingsRepository: LocalSettingsRepository(),
      apiClient: ValidationApiClient(),
    )..addListener(_refresh);

    _urlController = TextEditingController();
    _documentController = TextEditingController();

    _controller.initialize().then((_) {
      _urlController.text = _controller.apiBaseUrl;
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    _urlController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validador API'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL base del API',
              hintText: 'https://mi-api.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _controller.isLoading
                ? null
                : () => _controller.saveBaseUrl(_urlController.text),
            child: const Text('Guardar URL'),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: _controller.isLoading ? null : _controller.runHealthCheck,
            child: const Text('Probar conexión API'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _documentController,
            decoration: const InputDecoration(
              labelText: 'Documento a validar',
              hintText: '10203040',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _controller.isLoading
                ? null
                : () => _controller.validateDocument(_documentController.text),
            child: const Text('Validar documento'),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(child: Text(_controller.statusMessage)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
