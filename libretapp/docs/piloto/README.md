# Piloto offline: implementación y aceptación

**Estado vigente, 19 de octubre de 2026:** versión prevista `0.1.3+6`, respaldo
11, Android 9/API 28 mínimo. Consulte [las correcciones y evidencias actuales](../auditoria-2026-10-19/IMPLEMENTACION.md).
Los resultados que siguen documentan el candidato histórico del 2 de octubre;
no acreditan el árbol ni el paquete actuales.

Fecha de revisión: 2 de octubre de 2026 (Hermosillo). El candidato conserva `app.libret`, versión `0.1.1+4`, API objetivo 36 y formato de respaldo 9. El piloto es gratuito, sin cuenta y con datos locales.

## Resultado implementado

- Perfil con Resumen, Cuidados, Registros, Genealogía e Historial; cabecera persistente, fotografía ampliable y alternativa accesible sin foto.
- Hasta tres indicadores medidos y pertinentes al propósito; datos ausentes como «Sin registros». El listado y el perfil comparten cálculo y reglas.
- Menú Registrar adaptado a especie, sexo, propósito y estado. Los animales inactivos conservan consulta e historial y no muestran acciones operativas.
- Lote y ubicación con nombre y enlaces; actualización de datos e indicadores al regresar de un guardado. Ocupación de ubicaciones conectada a cambios de animales.
- Claro/oscuro seleccionable y persistente; ajustes de contraste, texto grande, áreas táctiles y separación inferior de contenido.
- Formularios de actividades de cultivos/ubicaciones y cuidados conservan captura al fallar; guardados bloquean duplicados y confirman tras persistir. Carga fallida tiene reintento.
- Variante Android `offline` con nube, cobros, cuentas e integraciones ocultas, sin permisos de Internet, GPS o Bluetooth. No necesita credenciales externas ni el núcleo de cifrado experimental para arrancar.
- Ayuda para el primer animal y el respaldo, información de almacenamiento local, fecha del último respaldo, borradores de privacidad y ficha de tienda.
- Isar Community 3.3.2 sustituye las bibliotecas de Isar 3.1 con alineación de 16 KB. Los esquemas de colecciones y UUIDs permanecen iguales; se probó apertura/escritura/reapertura de una base real de Isar 3.1.

## Evidencia y alcance

[Matriz de cobertura](directorio-cobertura.csv) y [hallazgos](hallazgos.md) registran superficies, pruebas, evidencias y recorridos pendientes. «Prueba automatizada» no significa que se haya ejecutado ese formulario en Android. «Pendiente» es una brecha de validación, no un fallo demostrado.

La evidencia local está en `artifacts/directorio/`, excluida de Git para no incorporar fotografías ni bases de datos a futuras contribuciones:

- `index.html`: comparación antes/después de las ocho especies en claro/oscuro y capturas Android.
- `before/`: capturas del perfil original a 360 dp; se conservaron los desbordamientos encontrados, sin alterar la captura.
- `after/`: capturas del nuevo perfil a 360 dp. Las pruebas adicionales recorren las cinco pestañas a 320/360/412 dp y texto 1×/2×.
- `android/`: capturas reales con su árbol de accesibilidad. Las primeras documentan el candidato intermedio; las terminadas en `final` documentan el APK final.
- `demo.libretbackup`: escenario ficticio de 40 animales, ocho especies y relaciones; no contiene datos de usuarios.
- `release-verification.json`: manifiesto y alineación ELF del AAB final. `performance-40.json` y `performance-1000.json`: medición de consultas locales.

La suite completa pasó 1,015 pruebas y la variante offline pasó otras 17. Se probaron errores de guardado, 48 combinaciones visuales del perfil y los ocho formularios de registro con texto doble y teclado. Las pruebas de persistencia y recuperación usan Isar real; las pruebas de interfaz usan repositorios controlados para reproducir fallos. Las capturas de widgets no sustituyen TalkBack ni permisos de cámara en un teléfono físico.

Rendimiento medido en Windows con Isar: lectura de 40 animales, mediana 6.93 ms; de 1,000, mediana 88.05 ms (p90 112.71 ms), con 23,000 registros hijos en el segundo caso. No representa latencia de dibujo ni desplazamiento en Android.

## Reproducir verificaciones

```powershell
flutter pub get
flutter test --reporter expanded
flutter analyze --no-fatal-infos
flutter test test/core/platform/offline_pilot_test.dart --dart-define=LIBRETAPP_OFFLINE_PILOT=true
$env:LIBRET_CAPTURE_DIR = 'artifacts/directorio/after'
flutter test test/features/directorio/animales/animal_profile_visual_test.dart
Remove-Item Env:LIBRET_CAPTURE_DIR
flutter build appbundle --release --flavor offline
flutter build apk --release --flavor offline
python tool/verify_offline_release.py build/app/outputs/bundle/offlineRelease/app-offline-release.aab --manifest build/app/intermediates/merged_manifests/offlineRelease/processOfflineReleaseManifest/AndroidManifest.xml --out artifacts/directorio/release-verification.json
```

En este Windows, Java necesitó las siguientes opciones para que el trabajador de Gradle pudiera comunicarse localmente; no forman parte de la configuración de la app:

```powershell
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:/Code/LibretApp/libretapp/build -Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.WindowsSelectorProvider'
```

Verificar también con `jarsigner -verify` y `zipalign -c -P 16 -v 4` del SDK. Conservar una copia segura externa de `android/upload-keystore.jks` y `android/key.properties`: no están en Git y la misma identidad permite las actualizaciones.

[Resumen verificable con hashes del AAB/APK y resultados](evidencia/validacion.json).

## Android y recuperación ejecutados

Se instaló el APK firmado sin credenciales en dos emuladores: Android 36.1 con páginas de 4 KB y Android 36 con `getconf PAGE_SIZE = 16384`. Ambos arrancaron con Wi-Fi y datos desactivados. Se exportó una copia desde el primer Android mediante el selector de archivos y se restauró en la instalación limpia del segundo.

El archivo exportado contiene 40 animales (37 activos), 16 ubicaciones, 6 lotes, 4 cultivos, 18 pesajes, 44 registros de salud, 5 reproducciones, 32 sesiones y 115 entradas de ordeña, 156 tareas y una fotografía. Las pruebas de recuperación real además comparan colecciones, parentesco, asignaciones y bytes de fotografía después de eliminar el directorio original de medios. En Android la fotografía restaurada se muestra en el perfil.

Se reinstaló el candidato con `adb install -r` y se confirmó conservación de los datos y del tema oscuro. La biblioteca antigua Isar 3.1 también se abre, escribe y reabre con el motor actualizado. La firma de un APK distribuido anteriormente no se conoce: no se afirma actualización desde una distribución histórica.

## Condiciones antes de subir a Play Console

1. Completar los recorridos manuales pendientes de la matriz, TalkBack, permisos rechazados, teclado/cancelación y pruebas en un teléfono de gama baja. No hay certificación de cobertura Android completa todavía.
2. Completar `privacidad.html` con el responsable y correo reales, publicarla en HTTPS y configurar `LIBRET_SUPPORT_EMAIL` y `LIBRET_PRIVACY_URL` al compilar. Los valores no se inventaron; el borrador no debe publicarse sin editar.
3. Completar recursos y declaraciones en [la ficha propuesta](play-store-ficha.md): icono, gráfico de funciones, capturas del build final, contenido, audiencia, anuncios y seguridad de datos. Revisar lo declarado frente al AAB final y sus SDKs.
4. Verificar la cuenta, activar Play App Signing y distribuir primero en pruebas internas. Con una cuenta personal creada después del 13/11/2023, cumplir al menos 12 participantes inscritos durante 14 días consecutivos antes de solicitar producción; se recomienda reclutar 15 y recoger comentarios reales.
5. Validar la actualización desde cualquier APK que ya se haya distribuido usando su firma original. La reinstalación conservando datos del candidato local y la compatibilidad de la base antigua no prueban una firma histórica desconocida.

Estos pasos requieren datos del titular, acceso a Play Console, participantes y pruebas humanas; no se ejecutaron acciones externas ni se publicó la app.

## Criterio de aceptación

El piloto se acepta cuando la matriz tiene evidencia de todas las superficies, no hay P0/P1 abiertos y funciona alta → registro → consulta → respaldo → restauración. Los hallazgos corregidos cuentan con pruebas; las brechas manuales siguen explícitas. El AAB local es un candidato de prueba y no una aprobación de publicación.

Después del piloto: recordatorios locales, gráficas de peso/producción y ficha para compartir. Cuentas, nube, RFID y monetización siguen fuera del piloto; el núcleo criptográfico continúa siendo prototipo.

Fuentes oficiales verificadas durante la ejecución: [API objetivo](https://support.google.com/googleplay/android-developer/answer/11926878), [16 KB](https://developer.android.com/guide/practices/page-sizes), [datos de usuarios](https://support.google.com/googleplay/android-developer/answer/10787469), [pruebas de cuentas personales](https://support.google.com/googleplay/android-developer/answer/14151465).
