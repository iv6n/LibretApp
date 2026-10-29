# Publicación Android y seguridad — 18 de octubre de 2026

## Dictamen y alcance

**Todavía no hay evidencia suficiente para aprobar producción en Google Play.** La variante `offline` ya implementa una base técnica razonable para una primera publicación gratuita. La variante `standard` con cuenta telefónica agrega bloqueos de privacidad, eliminación de cuentas y operación del proveedor que no existen en el piloto sin cuenta.

Esta auditoría revisó código y configuración Android, autenticación, separación de espacios locales, documentación y artefactos existentes. No modificó la implementación, no solicitó SMS, no creó cuentas, no entró en Play Console y no accedió a un proyecto Supabase de producción. No se imprimieron ni conservaron claves privadas, contraseñas o tokens. La ejecución final de compilación y pruebas del estado actual se registra en el informe principal; los resultados históricos citados aquí no la sustituyen.

## Variantes y alcance real

| Distribución | Estado de las capacidades | Consecuencia para publicación |
| --- | --- | --- |
| `offline` | Sin permiso de Internet, GPS o Bluetooth; teléfono y nube deshabilitados por código; invitado/demo y registros locales | Ruta más corta para el piloto. Requiere privacidad y ficha real, QA del build final y requisitos de la cuenta de Play |
| `standard` sin parámetros | Teléfono y nube desactivados por defecto; GPS y hardware disponibles por defecto; no equivale a una versión pública restringida | Hace falta una receta de compilación pública inequívoca |
| `standard` + `LIBRETAPP_PUBLIC_RELEASE=true` | Nube, hardware, GPS y proveedores ocultos; teléfono puede habilitarse por separado | El manifiesto sigue declarando GPS/Bluetooth aunque esas capacidades están deshabilitadas |
| `standard` + publicación pública + teléfono + Supabase configurado | Crea/verifica usuario remoto por SMS; datos del rancho permanecen locales | Exige privacidad aplicable, eliminación de cuenta dentro/fuera de la app, proveedor operativo y validación real |

Evidencia: `lib/core/platform/release_features.dart:12`, `:15`, `:20`, `:24`, `:30`, `:39`, `:46`; `android/app/src/offline/AndroidManifest.xml:3`; `lib/core/security/services/supabase_phone_auth.dart:28`, `:99`.

## Hallazgos prioritarios

### PUB-01 · P1 · Privacidad y soporte siguen incompletos

- **Alcance:** todas las variantes públicas; adicionalmente, la política existente solo cubre `offline`.
- **Evidencia:** `docs/piloto/privacidad.html:4` identifica el documento como borrador; `:6` conserva `{{RESPONSABLE}}` y `{{CORREO}}`; `:5`, `:12` y `:13` delimitan su aplicación a un piloto sin cuenta. `lib/core/platform/pilot_information.dart:10` y `:11` toman soporte y URL únicamente desde parámetros de compilación; `:47` y `:58` omiten esos campos si están vacíos. La compilación no exige valores.
- **Reproducción:** compilar cualquiera de las variantes sin `LIBRET_SUPPORT_EMAIL` ni `LIBRET_PRIVACY_URL`; abrir Perfil → Ajustes → Primeros pasos, privacidad y soporte. Los datos reales de contacto y la URL completa no aparecen.
- **Impacto:** no queda acreditada una política pública final ni un mecanismo real de contacto. No se puede aprobar la ficha pública solo con este borrador.
- **Cierre:** completar responsable/contacto, publicar una política HTTPS accesible, cubrir el tratamiento real de la variante elegida e incorporarla al build final y Play Console. Para teléfono, detallar autenticación/SMS, responsables/proveedores, conservación y eliminación. Google exige política incluso cuando no hay recolección remota: [política oficial de datos](https://support.google.com/googleplay/android-developer/answer/10144311).

### PUB-02 · P1 condicionado · No hay eliminación de cuenta telefónica

- **Alcance:** `standard` con teléfono habilitado y configurado; no bloquea un piloto puramente local.
- **Evidencia:** `supabase_phone_auth.dart:99`–`:104` llama a `signInWithOtp(shouldCreateUser: true)`. `lib/features/perfil/view/account_settings_card.dart:19`–`:54` solo implementa cierre de sesión y `:90`–`:94` solo lo ofrece como acción de cuenta. `lib/core/workspace/workspace_manager.dart:89`–`:107` desactiva el espacio y cierra la sesión, conservando datos. La búsqueda de eliminación de cuentas en `lib`, `tool` y documentación no encontró implementación ni recurso web de solicitudes.
- **Reproducción:** habilitar teléfono y verificar una cuenta; entrar en Perfil → Ajustes → Cuenta. Solo existe Cerrar sesión. No hay ruta para solicitar borrado remoto y de datos asociados.
- **Impacto:** cerrar sesión o desinstalar no elimina el usuario Supabase. Si se ofrece alta, Google exige un camino de solicitud desde la app y otro por web, con eliminación de datos asociados. Las identidades que solo operan offline quedan fuera de esa obligación: [requisito oficial de eliminación](https://support.google.com/googleplay/android-developer/answer/13327111).
- **Cierre:** implementar un flujo seguro de solicitud/borrado, reautenticación cuando corresponda y un recurso web funcional; definir qué ocurre con espacios/fotos/copias locales y datos retenidos. Ejecutar eliminación con privilegios solo en backend, nunca incluir una clave administrativa en Flutter. Como alternativa de alcance, publicar `offline` sin anunciar cuentas.

### PUB-03 · P1 condicionado · SMS y configuración de producción no están acreditados

- **Alcance:** publicación que anuncie o habilite cuentas por teléfono.
- **Evidencia:** `docs/supabase-sms.md:3` declara expresamente que no hay proyecto conectado, credenciales de cliente ni proveedor confirmado y que no se ha enviado/verificado SMS real. `docs/onboarding-cuentas.md:19`–`:23` enumera configuración externa pendiente. `lib/core/backup/supabase_config.dart:10` solo comprueba que URL y clave pública no estén vacías; no certifica el proyecto ni el proveedor.
- **Reproducción:** en el build actual sin configuración, elegir Crear cuenta con mi teléfono; `phone_auth_sheet.dart:199`–`:202` informa indisponibilidad. Un servidor simulado o `GET /auth/v1/settings` no acredita entrega.
- **Cierre:** verificar recepción y OTP correcto/incorrecto/vencido, reenvío, red lenta/sin red, dos cuentas, vinculación del invitado, cierre y reingreso en Android físico. Registrar versión, dispositivo y resultado sin números completos, OTP ni tokens.
- **Control de abuso pendiente:** la espera local de 60 s (`phone_auth_sheet.dart:77`) puede reiniciarse al corregir número (`:286`–`:295`) o reabrir la hoja; la defensa debe estar en el proveedor. La app no pasa `captchaToken` y la guía ya lo reconoce (`docs/supabase-sms.md:45`–`:47`). Revisar límites de servidor y controles de costos; esto no demuestra que el backend esté desprotegido, pues su configuración no fue accesible.

### PUB-04 · P2 · Permisos de la variante pública con teléfono exceden su alcance anunciado

- **Alcance:** `standard` con `LIBRETAPP_PUBLIC_RELEASE=true`.
- **Evidencia:** `android/app/src/main/AndroidManifest.xml:3`–`:12` declara ubicación y Bluetooth; `release_features.dart:30`–`:42` deshabilita hardware/GPS en publicación pública. El manifiesto merged `standardRelease` encontrado conserva esos permisos. `offline` sí los elimina por overlay.
- **Reproducción:** compilar `standard` pública y revisar el manifiesto final. Los parámetros Dart no eliminan permisos del manifiesto.
- **Cierre:** definir una variante pública con Internet y permisos mínimos si la primera versión con cuenta no ofrece GPS/lectores. Si se decide ofrecerlos, certificar hardware y comportamiento con permisos rechazados y describir el uso real. No se observó un permiso de ubicación en segundo plano ni permisos de SMS/registro de llamadas.

### PUB-05 · P2 · El onboarding ofrece una cuenta no disponible en `offline`

- **Alcance:** `offline`, y cualquier `standard` sin teléfono configurado.
- **Evidencia:** `lib/features/onboarding/onboarding_page.dart:150`, `:194`–`:209` muestra el botón Crear cuenta y el texto de reingreso sin comprobar disponibilidad. `account_settings_card.dart:81`–`:88` ofrece Vincular mi número al invitado. El servicio sí bloquea la función (`supabase_phone_auth.dart:28`–`:34`) y la hoja explica la indisponibilidad (`phone_auth_sheet.dart:199`–`:202`).
- **Reproducción:** instalación limpia offline → Saltar → Crear cuenta con mi teléfono. Se abre una hoja que indica que la función no está disponible.
- **Impacto:** la implementación no crea una cuenta falsa, pero la primera acción destacada del piloto no se puede completar y contradice `docs/piloto/README.md:13`, que dice que cuentas están ocultas.
- **Cierre:** mostrar elección y textos coherentes con la variante, o explicar la disponibilidad antes de abrir una acción inoperante.

### PUB-06 · P2 · La evidencia del candidato anterior no certifica este release

- **Evidencia:** `pubspec.yaml:19` declara `0.1.2+5`. `docs/piloto/evidencia/validacion.json:3`–`:4` y `:211` documenta `0.1.1+4`. El AAB encontrado en `build/app/outputs/bundle/offlineRelease/app-offline-release.aab` tenía SHA-256 `85D802B78AFD130A410E323385D438261EA4C62C51CBDF3DAE283E6DB4E4834A`, distinto del hash histórico `docs/piloto/evidencia/validacion.json:186`.
- **Resultado propio:** `jarsigner -verify` sobre ese AAB devolvió `jar verified`. También advirtió certificado autofirmado/sin timestamp y diferencias de lectura por orden del manifiesto (`JarFile`/`JarInputStream`). Esto no demuestra rechazo de Play ni sustituye validación por Play/bundletool.
- **Cierre:** generar el AAB del commit/árbol revisado, guardar hash y parámetros de compilación no secretos, verificar firma, manifiesto, ELF de bibliotecas nativas y APKs generados desde el AAB, y probar instalación/actualización/recuperación. No emparejar automáticamente un AAB antiguo con un XML merged generado en otra compilación.

### PUB-07 · P2 · CI no verifica el paquete distribuible

- **Evidencia:** `../.github/workflows/flutter_test.yml:18`–`:34` usa Flutter stable sin fijar versión y corre dependencias, análisis y pruebas. `:36`–`:41` prueba las restricciones mediante `LIBRETAPP_OFFLINE_PILOT=true`; `:43`–`:54` añade pruebas SQL Supabase. No compila AAB ni ejecuta verificación de firma/manifiesto/alineación o instalación Android.
- **Riesgo:** una suite verde no detecta fallos exclusivos de Gradle, manifest merge, flavor real o bibliotecas nativas del release.
- **Cierre:** añadir un job reproducible para la variante pública seleccionada y conservar reporte/hash de sus artefactos; firma privada gestionada en secretos/entorno autorizado. Mantener pruebas de restricciones con el flavor real y teléfono/nube solicitados explícitamente.

## Controles que sí están implementados

- SDK Android: `android/app/build.gradle.kts:28`, `:43`, `:47` fija `compileSdk=36`, identidad `app.libret` y `targetSdk=36`; `:52` incluye `arm64-v8a`. Los manifiestos merged existentes de ambas variantes reportaban minSdk 24, target 36, versión 0.1.2/5 y `allowBackup=false`. Son una observación de artefactos locales, no aprobación de Play.
- Firma: `build.gradle.kts:17`–`:23` rechaza tareas release sin archivo privado; `:68`–`:83` usa la firma release y no debug. Se confirmó existencia de cuatro propiedades no vacías sin revelar valores. `android/key.properties` y `android/upload-keystore.jks` están ignorados y no aparecen en `git ls-files`. No se comprobó la identidad de un APK distribuido históricamente ni copia externa de recuperación.
- `offline` elimina los permisos sensibles del main manifest (`src/offline/AndroidManifest.xml:3`–`:9`). El merged local solo conserva `ACCESS_NETWORK_STATE` y un permiso propio de receptor no exportado. `src/main/AndroidManifest.xml:18` desactiva respaldo Android.
- OTP comprueba que existan sesión, usuario y teléfono confirmado y coincidente antes de aceptar identidad (`supabase_phone_auth.dart:111`–`:127`); aplica tiempos de espera y mensajes de error sin exponer OTP/token (`:36`–`:95`).
- Sesiones telefónicas: `SecureSessionStorage` usa `FlutterSecureStorage` (`secure_session_storage.dart:6`–`:13`, `:34`–`:39`) y retira sesiones antiguas guardadas en preferencias (`:15`–`:27`). La persistencia segura precede al cambio de propietario (`supabase_phone_auth.dart:125`).
- Separación local: la cuenta se asocia por UID verificado; vincular un invitado conserva su espacio y crea otro invitado; los conflictos entre espacios requieren elección (`workspace_manager.dart:38`–`:69`). Cierre de sesión persiste primero la desactivación (`:97`–`:103`). La sesión remota no sincroniza registros ni sustituye un respaldo.
- El acceso falso heredado se bloquea por defecto en release (`auth_service.dart:18`–`:35`). La nube permanece deshabilitada en la publicación pública (`release_features.dart:15`–`:17`), y los adaptadores de nube se seleccionan solo con flags/configuración (`injection_native.dart:299`, `:351`, `:603`).
- El núcleo nativo sigue siendo prototipo: nonce basado en tiempo y cifrado XOR (`native/libret_core/src/libret_secure_api.cc:17`–`:25`, `:124`–`:130`); su README lo reconoce (`native/libret_core/README.md:21`). La inyección rechaza usarlo como cifrado de producción (`injection_native.dart:322`–`:335`). No se considera protección de la base local o de los respaldos y no bloquea por sí solo el piloto local ni el flujo telefónico con almacenamiento seguro del sistema.
- La política borrador describe correctamente que los respaldos locales son legibles y no tienen cifrado propio (`docs/piloto/privacidad.html:10`, `:12`). No se debe anunciar cifrado de extremo a extremo de los registros.

## Lista de salida Google Play

| Requisito | Estado observado / evidencia necesaria |
| --- | --- |
| API objetivo vigente | Configurado 36. Desde 31/08/2026 Google exige 36 para nuevas apps/actualizaciones de teléfono: [fuente oficial](https://support.google.com/googleplay/android-developer/answer/11926878) |
| Identidad/versionado | `app.libret`, 0.1.2+5. Confirmar que el versionCode supere todo lo ya subido a Console; el script local solo comprueba `>=4`, no conoce Console (`tool/verify_offline_release.py:52`) |
| AAB firmado y Play App Signing | Firma local disponible; falta acreditar carga/aceptación de Console y respaldo seguro de clave de carga |
| Bibliotecas nativas 16 KB | Dependencias y AGP actualizados; evidencia histórica favorable. Verificar el paquete final, no solo `liblibret_core.so`. Android recomienda revisar ELF, empaquetado y ejecución real: [guía oficial](https://developer.android.com/guide/practices/page-sizes). La página actual menciona bloqueo de actualizaciones no compatibles desde 01/02/2027; confirmar cualquier requisito concreto mostrado por Console |
| Privacidad y soporte | Bloqueo PUB-01; no se probó URL real publicada |
| Data safety | Completar según variante y SDKs. Incluso sin recolección requiere formulario y política para pistas cerradas/abiertas/producción; solo internal testing está exenta: [guía oficial](https://support.google.com/googleplay/android-developer/answer/10787469) |
| Eliminación de cuenta | Bloqueo PUB-02 cuando se habilita teléfono. No aplica a una identidad que opera exclusivamente offline |
| Acceso del revisor | Invitado/demo permiten evaluar funciones locales. Si se publica teléfono, preparar instrucciones de revisión y acceso verificable sin depender de un número privado del titular |
| Contenido, público, anuncios, permisos y funciones financieras | Completar declaraciones Console según funcionalidades realmente distribuidas; no se tuvo acceso a ese estado |
| Ficha e imágenes del build final | Existe borrador en `docs/piloto/play-store-ficha.md`; confirmar icono/gráfico/capturas finales y datos reales del desarrollador antes de publicarlo |
| Prueba cerrada cuando aplique | Cuenta personal creada después de 13/11/2023: mínimo 12 participantes inscritos 14 días consecutivos antes de solicitar producción. Su cumplimiento depende de Console y participantes: [fuente oficial](https://support.google.com/googleplay/android-developer/answer/14151465) |
| Validación Android humana | Falta acreditar build final en teléfono físico, TalkBack, texto ampliado, teclado, cancelación, permisos rechazados, cierre forzado, poco almacenamiento, exportación/recuperación y actualización desde versión realmente distribuida |
| Operación de SMS si se ofrece | PUB-03; sin proyecto/proveedor real validado no se considera función lista |

## Orden recomendado

1. Elegir explícitamente el alcance del primer release: piloto `offline`, o `standard` con cuentas. La app local no necesita un backend remoto para registrar información.
2. Resolver los P1 que correspondan a ese alcance y los defectos de integridad/UI del informe principal.
3. Completar datos reales de privacidad/soporte y preparar una receta de compilación reproducible que los exija.
4. Congelar candidato, ejecutar pruebas y verificación del AAB final con hash y prueba de recuperación/actualización.
5. Subir a pruebas internas, revisar el informe previo al lanzamiento y después completar prueba cerrada/requisitos de producción aplicables. Este análisis no ejecutó ninguna publicación.
