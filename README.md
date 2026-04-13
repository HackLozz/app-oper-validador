# almuerzos_colsubsidio_2

App Flutter para control de acceso con biometría facial y respaldo de validación en backend, pensada para tablets en modo kiosko.

## Qué hace

- **Enroll**: captura rostro + carnet, extrae `docNumber` desde barcode, genera embedding facial y guarda en Hive.
- **Verify**: captura solo rostro, identifica la cédula por mejor match facial local y valida el documento en backend con JWT.
- **Modo vigilante**: en Home, cuando no hay un rostro cercano la app entra en espera; al detectar proximidad facial se activa el menú automáticamente.
- Operación híbrida: matching facial local + validación de documento en API (app-oper-gestor).

## Stack técnico

- Flutter / Dart
- `camera` para captura de imágenes
- Google ML Kit: face detection, barcode, OCR
- TFLite (`mobilefacenet.tflite`) para embeddings faciales
- Hive para persistencia local

## Requisitos

- Flutter SDK compatible con `sdk: >=3.0.0 <4.0.0`
- Android tablet con cámara frontal
- Permisos de cámara y configuración kiosk (si aplica)

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

> En este repositorio la lógica principal está optimizada para Android tablet.

## Flujo funcional

### Enroll

1. Validación de rostro (1 cara, luz/distancia, anti-spoof rápido).
2. Lectura de barcode de carnet.
3. Confirmación OCR de texto “colsubsidio”.
4. Guardado en `face_id_box` con:
   - `docNumber` (key)
   - `barcodeRaw`
   - `embeddingBytes` / `embeddingBytesList`
   - `selfiePath`

### Verify

1. Captura de 2 muestras faciales (probes).
2. Búsqueda del mejor match facial en base local (`face_id_box`).
3. Obtención de cédula candidata (`docNumber`) por mayor score promedio.
4. Validación en backend enviando `Authorization: Bearer <JWT con sub=docNumber firmado con TABLET_SECRET_KEY>`.
5. Solo valida rostros dentro del overlay ovalado (fuera del óvalo no avanza).
6. Resultado final permitido/denegado por umbral facial y respuesta del API.
7. Si la API cae, reintenta en segundo plano y usa datos ya validados para operar offline sin interrumpir la experiencia de acceso.
8. Cuando la API se reconecta, sincroniza internamente los documentos pendientes validados en offline.
9. Si la cédula ya tuvo acceso exitoso en la sesión activa, bloquea intento duplicado con sonido de denegación.

## Modo vigilante

- Activo en `HomeMenuPage`.
- Usa la cámara frontal + detector de rostro en polling.
- Si detecta rostro con área relativa suficiente, activa menú.
- Si no detecta cercanía durante unos segundos, vuelve a modo espera.

## Estructura relevante

- `lib/features/face_id/pages/` UI de enroll/verify/home/records
- `lib/features/face_id/controllers/` controladores de flujo y modo vigilante
- `lib/features/face_id/utils/card_utils.dart` parsing/normalización de texto y barcode
- `lib/services/face/` embeddings, verificación y codec de registros
- `lib/data/hive/` boxes y acceso a persistencia

## Notas operativas

- El umbral por defecto de verify está en `0.55`.
- Se mantiene compatibilidad de lectura de embeddings con esquema nuevo y legacy.
- Para producción, cambia el PIN admin y valida parámetros de cámara/luz por dispositivo.


## Despliegue para 3 tablets (2 validación + 1 registro)

La app ahora soporta **modo por tablet** y **cluster de base local compartida por configuración**.

Variables nuevas:
- `TABLET_MODE`: `validation` | `register` | `full`
- `TABLET_CLUSTER`: identificador del grupo de tablets (todas deben usar el mismo valor)
- `TABLET_STATION`: etiqueta opcional de estación (ej: `bio-01`, `bio-02`, `registro-01`)

### Ejemplos recomendados

**Tablet 1 y 2 (biométrico / validación):**
```bash
flutter run   --dart-define=TABLET_MODE=validation   --dart-define=TABLET_CLUSTER=almuerzos_sede_norte   --dart-define=TABLET_STATION=bio-01
```

```bash
flutter run   --dart-define=TABLET_MODE=validation   --dart-define=TABLET_CLUSTER=almuerzos_sede_norte   --dart-define=TABLET_STATION=bio-02
```

**Tablet 3 (solo registro):**
```bash
flutter run   --dart-define=TABLET_MODE=register   --dart-define=TABLET_CLUSTER=almuerzos_sede_norte   --dart-define=TABLET_STATION=registro-01
```

> Importante: el cluster define el nombre de la base local Hive (`face_id_box_<cluster>`). Usa el mismo valor en las 3 tablets para mantener la misma estructura de persistencia local y cache.

## Configuración backend (app-oper-gestor)

Usa `--dart-define` al ejecutar la app:

```bash
flutter run \
  --dart-define=VALIDATION_API_BASE_URL=http://10.1.49.237:8000 \
  --dart-define=VALIDATION_TABLET_SECRET_KEY=tablet-super-secret \
  --dart-define=VALIDATION_TABLET_ALGORITHM=HS256 \
  --dart-define=VALIDATION_API_ENDPOINT=/api/v1/validation/check \
  --dart-define=VALIDATION_API_TIMEOUT_MS=8000 \
  --dart-define=VALIDATION_API_RETRIES=1
```

Si no se configuran `VALIDATION_API_BASE_URL` y `VALIDATION_TABLET_SECRET_KEY`, la validación de backend fallará y el acceso será denegado por seguridad.

Sugerencia de entorno para producción:
- `VALIDATION_API_BASE_URL`: URL pública o IP accesible desde la tablet (no usar `localhost` en dispositivo real).
- `VALIDATION_API_TIMEOUT_MS`: tiempo máximo de espera por intento.
- `VALIDATION_API_RETRIES`: reintentos automáticos cuando hay errores de red.


### Modo prueba de API desde tablet

En **modo admin**, en Home aparece una tarjeta adicional **API PRUEBA** (mismo tamaño que ENROLL/VERIFY).
Además, en la pantalla **Verify Facial** hay dos accesos visibles: el icono en la barra superior y un botón flotante **API Prueba** en la parte inferior derecha.
Desde allí puedes:
- Escribir una URL base de API de prueba (por ejemplo `http://10.1.49.237:8000`).
- Probar comunicación con el backend.
- Guardar la URL para que Verify use esa dirección desde la tablet.

La URL queda persistida en almacenamiento local y se usa en reinicios posteriores.
flutter run
