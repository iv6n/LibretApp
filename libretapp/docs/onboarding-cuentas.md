# Onboarding y cuentas telefónicas

Implementación para Android sobre `0.1.2+5`. La autenticación identifica una cuenta; los registros del rancho, fotografías, borradores y respaldos internos permanecen en el dispositivo. No se agregan sincronización ni respaldo remoto.

## Recorrido

En una instalación nueva hay dos pantallas de bienvenida: **Cuidar empieza aquí**, para elegir **Mascotas y plantas** o **Ganado y campo**, y una vista previa adaptada con **Empezar sin cuenta**, **Probar con ejemplos** y, si está disponible, **Crear o abrir cuenta con mi teléfono**. Elegir una experiencia y empezar sin cuenta requiere dos pulsaciones; después se ofrece el perfil opcional antes de Inicio. **Cambiar elección** y el botón Atrás de Android permiten volver. El progreso se conserva entre aperturas; las páginas antiguas 0–4 se reanudan en acceso. Entrar sin cuenta o verificar el teléfono completa la bienvenida.

El paso independiente **Un toque personal**, en `/bienvenida/perfil`, lleva la etiqueta **Opcional** y queda fuera del contador de bienvenida. Nombre, apellidos, correo y teléfono se muestran en ambas experiencias. En Ganado y campo, **Añadir datos del rancho** permite desplegar nombre del rancho, UPP y dirección. Todos los campos son opcionales: **Guardar y empezar** acepta incluso el formulario vacío y **Ahora no** permite omitirlo sin guardar lo escrito. Atrás cierra primero el teclado; con el teclado cerrado omite el paso.

`ProfileOnboardingService` reutiliza `PerfilRepository` y guarda `onboarding.profile.resolved.v1` en las preferencias del espacio correspondiente. El arranque y el primer acceso ofrecen el paso si los siete datos están vacíos y aún no se resolvió. Cualquier dato personal o del rancho existente evita la invitación; región y producción no cuentan para esta comprobación. Las demos omiten el paso. Guardar u omitir lo resuelve; cerrar antes de decidir no guarda borradores y permite retomarlo. Un error de guardado conserva el formulario para reintentar; un error al registrar la omisión permite continuar durante esa sesión, aunque podría repetirse la invitación al volver a abrir si no se logró persistir la marca.

Estos datos se guardan localmente. El teléfono de contacto no envía SMS, verifica identidad ni cambia el teléfono de acceso; el correo no crea una cuenta. Se recortan espacios exteriores, solo se valida el formato básico de un correo escrito y se conservan prefijos, espacios y guiones del teléfono y ceros iniciales de UPP. El editor de Perfil también permite dejar nombre y apellidos vacíos. Un perfil vacío presenta **Mi perfil** y **Añadir datos opcionales**. No se agregan tablas ni se modifica el formato de respaldos.

El invitado no crea un usuario anónimo en Supabase ni requiere Internet. Puede vincular su espacio desde **Perfil → Ajustes → Cuenta → Vincular mi número**. La verificación conserva el mismo espacio y sus identificadores. Si la cuenta ya tiene otro espacio en este dispositivo, se ofrece abrirlo o seguir como invitado, sin combinar datos.

Cada cuenta tiene datos locales separados. Cerrar sesión conserva los registros y exige verificar el teléfono para volver a abrir esa cuenta. La caducidad de una sesión remota no impide trabajar localmente mientras el espacio siga activo. En otro dispositivo, entrar en la misma cuenta no recupera registros: se necesita importar un respaldo completo.

Cada experiencia ofrece su propia demo editable, temporal y con base, preferencias y archivos separados. La doméstica incluye Luna (perra), Milo (gato), una planta, un huerto y tres actividades con fechas relativas a la apertura; la ganadera conserva su escenario existente. Ambas tienen rótulo permanente y salida visible. Salir descarta los cambios y vuelve al acceso con la experiencia elegida. Si se interrumpe el proceso, el próximo arranque elimina ese espacio temporal. Las demos no completan la bienvenida, no crean cuentas, no exportan respaldos ni programan notificaciones reales. Para cambiar de experiencia se sale primero de la demo.

## Configuración necesaria para SMS reales

La integración está implementada; un envío real requiere un proyecto y un proveedor configurados. No hay credenciales de proveedor incluidas ni se contrata ningún servicio desde el código.

Seguir la [configuración detallada de Supabase y Twilio Verify](supabase-sms.md), con el ejemplo `onboarding.dart-define.example.json` y el diagnóstico sin envío `tool/check_phone_auth.ps1`.

1. Usar un proyecto Supabase de producción y habilitar el proveedor de autenticación **Phone**.
2. Configurar en Supabase el proveedor SMS y sus credenciales. Mantenerlas exclusivamente del lado del servicio, nunca en Flutter.
3. Configurar códigos de seis dígitos y un intervalo mínimo de reenvío de 60 segundos, consistente con el formulario. Revisar límites de solicitudes y protecciones del proyecto antes de distribuir. La expiración la aplica el servidor; el cliente informa códigos incorrectos o vencidos.
4. Completar la política de privacidad y soporte. La política debe explicar que el número se envía al servicio de autenticación; los registros del rancho permanecen locales.
5. Probar en un Android físico con un número autorizado: recepción, código válido, incorrecto y vencido, reenvío, falta de red, cierre de sesión y reingreso. Las pruebas automatizadas con servidor simulado no acreditan entrega real de SMS.

Referencias: [configuración de acceso telefónico](https://supabase.com/docs/guides/auth/phone-login), [solicitud OTP para Dart](https://supabase.com/docs/reference/dart/auth-signinwithotp), [verificación OTP](https://supabase.com/docs/reference/dart/auth-verifyotp).

Crear un archivo local ignorado por Git, por ejemplo `onboarding.dart-define.local.json`, con valores reales en lugar de estos campos:

```json
{
  "LIBRETAPP_PUBLIC_RELEASE": "true",
  "LIBRETAPP_ENABLE_PHONE_AUTH": "true",
  "SUPABASE_URL": "[SUPABASE_URL]",
  "SUPABASE_ANON_KEY": "[CLAVE_PUBLICA_SUPABASE]",
  "LIBRET_SUPPORT_EMAIL": "[CONTACTO_SOPORTE]",
  "LIBRET_PRIVACY_URL": "[URL_PRIVACIDAD]"
}
```

Utilizar una clave pública Publishable (`sb_publishable_...`) o la clave `anon` heredada, nunca `service_role` ni `sb_secret_...`. Construir la distribución con acceso a Internet:

```powershell
flutter build apk --flavor standard --dart-define-from-file=onboarding.dart-define.local.json
```

La firma de release conserva los requisitos privados existentes del proyecto. La variante `offline` retira el permiso de Internet y deshabilita el acceso por teléfono; invitado y demo siguen disponibles. Si falta configuración, la interfaz explica la indisponibilidad y no simula una cuenta creada.

La activación de teléfono es independiente de nube, sincronización, GPS y hardware. `LIBRETAPP_ENABLE_CLOUD_DATA` permanece desactivado por defecto y no se habilita en la publicación pública. Supabase se inicializa al solicitar autenticación, sin bloquear el arranque local. La sesión se conserva mediante almacenamiento seguro del dispositivo y no forma parte de respaldos ni preferencias de trabajo.

## Persistencia y compatibilidad

`WorkspaceRegistry` conserva un único documento versionado con los espacios y el identificador activo. Cada cuenta se asocia por el identificador de usuario de Supabase; se conservan solo los últimos cuatro dígitos para reconocerla visualmente. El número editable de contacto del perfil no verifica identidad.

Los espacios nuevos usan base y directorio propios. Preferencias, fotos importadas, copias previas a restauración y repositorios dependen del espacio activo. Cambiar de espacio desmonta el árbol de navegación y sus BLoCs antes de cerrar Isar y reconstruir los servicios. Tema, idioma y progreso general de onboarding son compartidos.

Una instalación anterior conserva su base y rutas de fotografías originales como espacio de invitado. No se borran registros previos, incluidos ejemplos que ya hubieran estado mezclados en versiones internas. Se reconoce información de todos los módulos; los valores predeterminados del perfil y los registros técnicos de arranque no cuentan como información capturada por el usuario.

El respaldo completo exporta solo el espacio abierto, con sus registros y archivos compatibles con el formato actual. No exporta el registro de cuentas, verificaciones ni sesiones. Importar un respaldo no cambia la identidad propietaria del espacio. Excel sigue siendo una exportación de consulta y no sustituye el respaldo completo.

## Validación antes de publicar

- Instalar en limpio, avanzar, retroceder, saltar y reabrir tras interrumpir la introducción.
- Crear un animal y una actividad sin conexión como invitado; cerrar y abrir la app.
- Vincular ese invitado; comprobar las mismas fichas, fotos e historial.
- Probar dos cuentas, cierre de sesión y el conflicto con un invitado que contiene registros.
- Editar la demo y salir; confirmar que los espacios reales y sus respaldos no cambian.
- Actualizar una instalación anterior con animales o información de otros módulos.
- Renovar capturas de Instagram y comprobar texto ampliado y temas claro y oscuro.
- Confirmar SMS reales, campos de privacidad y soporte, firma y enlace público antes de anunciar cuentas disponibles.

La verificación real del proveedor SMS, el enlace de descarga pública y los campos de soporte y privacidad siguen siendo requisitos externos de publicación.

## Comprobaciones de esta entrega · 18 de octubre de 2026

Se aprobaron 63 pruebas de onboarding, cuentas, persistencia aislada, sesión segura, demo, respaldos, perfil y representación visual. También se comprobaron los parámetros de la variante offline con autenticación y nube solicitadas explícitamente: ambas permanecen deshabilitadas. Las pruebas automatizadas de SMS usan respuestas simuladas de Supabase.

Se generaron capturas reales de los widgets Flutter para la bienvenida y la elección de acceso, y un APK `standard` de depuración para revisar el recorrido. El APK inicial `artifacts/onboarding/LibretApp-onboarding-debug.apk` no contiene configuración de Supabase y permite probar invitado y demo.

Posteriormente se creó el proyecto Supabase **LibretApp** (`ylbmwsgaavonqmwhdpci`) y se generó `artifacts/onboarding/LibretApp-supabase-debug.apk` con su URL y clave pública, mediante `onboarding.dart-define.local.json` ignorado por Git. Se comprobó la compilación Android, el paquete `app.libret`, versión `0.1.2+5` y permiso de Internet. **Phone está activado con Twilio Verify** y el diagnóstico real confirma que Supabase responde, permite altas y exige el código. El servicio Verify usa seis dígitos, SMS y Fraud Guard Standard. El token del proveedor se guardó en Supabase con autorización del propietario; no está incluido en el APK ni en archivos locales.

El 19 de octubre se comprobó recepción real de SMS y, posteriormente, acceso desde un OPPO CPH2123 con Android 12 y `0.1.3+6`. Se actualizó por ADB a la variante `standard release` con la misma firma y sin desinstalar. La app muestra la cuenta terminada en 4477 como verificada; una consulta de lectura a `auth.users` confirmó una cuenta con teléfono confirmado e inicio de sesión registrado. Al reiniciar el proceso volvió a Inicio sin repetir el onboarding. El último SMS autorizado al agente no se solicitó porque la cuenta ya estaba verificada. Evidencia y consulta: [prueba física](supabase-sms.md#resultado-de-la-prueba-física).

La cuenta Twilio sigue en prueba; el intento de añadir el otro destinatario mexicano fue rechazado por una restricción de Caller ID por SMS. Siguen pendientes el reingreso después de cerrar sesión, las demás pruebas reales de aceptación y habilitar el proveedor para destinatarios públicos. No anunciar acceso telefónico público hasta completar esas condiciones.
