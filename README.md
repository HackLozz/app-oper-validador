# almuerzos_colsubsidio_2

Aplicación Flutter para validar documentos contra un API remoto de forma simple y mantenible.

## Mejoras aplicadas

- Se eliminó conflicto de merge en `pubspec.yaml`.
- Se reorganizó el código en capas:
  - `presentation`: pantalla y controlador.
  - `data`: cliente HTTP y persistencia local de configuración.
  - `domain`: modelo de respuesta.
  - `core/config`: utilidades compartidas y configuración por `--dart-define`.
- Se agregó flujo para:
  - Guardar URL base del API en almacenamiento local.
  - Probar conexión (`/health`).
  - Validar un documento en el endpoint configurable.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Configuración por entorno

Puedes pasar estos valores desde CLI:

```bash
flutter run \
  --dart-define=VALIDATION_API_BASE_URL=https://tu-api.com \
  --dart-define=VALIDATION_API_ENDPOINT=/api/v1/validation/check \
  --dart-define=VALIDATION_API_TIMEOUT_MS=8000
```

## Uso rápido

1. Abre la app.
2. Escribe la URL base del API y pulsa **Guardar URL**.
3. Pulsa **Probar conexión API**.
4. Escribe el documento y pulsa **Validar documento**.

La URL queda persistida en el dispositivo para siguientes sesiones.
