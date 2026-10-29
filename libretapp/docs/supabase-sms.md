# Configurar cuentas por teléfono: Supabase y SMS

Estado al 19 de octubre de 2026: el proyecto **LibretApp** (`ylbmwsgaavonqmwhdpci`) está activo en Supabase. Su URL y clave pública Publishable están configuradas en `onboarding.dart-define.local.json`, ignorado por Git. **Phone está activado con Twilio Verify**. El diagnóstico real confirmó que responde, permite altas y exige confirmar el teléfono. La prueba física con `0.1.3+6` en un OPPO CPH2123 confirmó el acceso de la cuenta terminada en **4477**: la app muestra la cuenta verificada y una consulta de lectura a `auth.users` confirmó una cuenta, teléfono confirmado e inicio de sesión registrado. Al reiniciar el proceso, la app volvió a Inicio sin repetir el onboarding. Siguen pendientes el reingreso después de cerrar sesión, las demás pruebas de aceptación y la habilitación del proveedor para destinatarios públicos.

Proyecto: [panel de LibretApp](https://supabase.com/dashboard/project/ylbmwsgaavonqmwhdpci). Organización gratuita LibretApp; región asignada `us-east-1`. La contraseña de la base de datos no se incluye en la configuración de Flutter. Soporte y política de privacidad siguen pendientes; se dejan vacíos para no mostrar enlaces ficticios en la app.

Twilio tiene una cuenta de prueba y el servicio Verify **LibretApp**, con códigos de seis dígitos, **SMS habilitado** y **Fraud Guard activo, nivel Standard**. Con autorización del propietario se guardaron la declaración del nombre y la conexión de Twilio Verify en Supabase. El Auth Token se transfirió entre los formularios del navegador y quedó guardado únicamente en el proveedor de Supabase; no se incluyó en el chat, el APK ni archivos locales. La sesión de la app continúa usando el almacenamiento seguro del dispositivo.

El propietario eligió inicialmente otro destinatario, terminado en **3453**, que no aparece entre los números verificados de Twilio. Se preparó **Phone Numbers → Manage → Verified Caller IDs → Add a new Caller ID** para su verificación previa. Los intentos manuales del propietario fueron rechazados como se explica a continuación. No guardar el número completo ni códigos en documentos compartidos.

Revisión del 19 de octubre: la consola mostró que la verificación mediante **Call** no está soportada en esta cuenta de prueba. Se cambió el formulario a **SMS**, se repuso el número elegido y se comprobó que SMS quedó seleccionado. El agente no solicitó códigos de alta de Caller ID.

El siguiente intento manual por SMS mostró otro rechazo: Twilio restringe **la verificación de Caller ID por SMS para ese país**. Por tanto, cambiar de Call a SMS no resolvió el alta del destinatario mexicano en esta cuenta. No repetir esos intentos como solución. El bloqueo observado pertenece al alta previa de destinatarios de Twilio; no demuestra que todo envío de Verify a México esté prohibido. Se revisó también el flujo **Try it out** del servicio existente: su lista solo ofrece el destinatario terminado en **4477**, ya verificado, y no contiene una opción para agregar otro. El propietario autorizó un único SMS de prueba a ese destinatario. Se solicitó mediante `POST /auth/v1/otp` de Supabase y su recepción quedó confirmada, sin reintentos automáticos. Twilio detectó el intento externo por SMS para México, con seis dígitos y sin error de proveedor en ese registro. La comprobación del código debe pasar por Supabase para confirmar también la cuenta; verificar únicamente en la consola de Twilio no acredita una sesión de LibretApp. Para el número terminado en 3453 sigue pendiente resolver la restricción con Twilio. El paso a una cuenta de pago y su perfil de cumplimiento requieren decisión del propietario; no garantizan por sí solos la entrega.

Posteriormente, el 19 de octubre, el propietario pidió reintentar la verificación del número terminado en 4477. Se realizó un único reintento desde **Try it out** del servicio Verify existente: Twilio respondió **201 Created**, canal SMS y estado inicial **pending**. El propietario introdujo el código y pulsó **Verify** personalmente. Se comprobó en **Verify → Overview → Verification Logs** que el intento de las **15:03:05 UTC** terminó en **Approved**, con **1/1** intentos verificados/enviados. El intento anterior de las 14:59:50 UTC también figura aprobado; el envío de Supabase de las 06:11:34 UTC figura vencido. La prueba directa acredita el funcionamiento de Twilio, pero no confirma por sí sola la cuenta ni una sesión de LibretApp: falta solicitar y verificar un código nuevo desde Android mediante Supabase.

## 1. Proyecto Supabase

Entrar al [panel de Supabase](https://supabase.com/dashboard) y elegir el proyecto de LibretApp. Si aún no existe, crear uno en la organización del propietario. Conservar la contraseña de la base de datos en un gestor de contraseñas; no se utiliza en Flutter. Revisar el plan elegido antes de aceptar cargos.

En el diálogo **Connect** o en **Project Settings → API Keys**, obtener la URL del proyecto y una clave **Publishable** (`sb_publishable_...`). La clave `anon` heredada también sirve. No usar `service_role`, una clave `sb_secret_...` ni un token personal de administración en el APK.

No es necesario ejecutar las migraciones de los módulos del rancho para este acceso: Supabase Auth administra la identidad; los registros continúan en el teléfono. `supabase/config.toml` configura desarrollo local y no habilita por sí solo el servicio alojado. [Guía oficial de Phone](https://supabase.com/docs/guides/auth/phone-login).

## 2. Proveedor conectado: Twilio Verify

Esta es la ruta recomendada para la primera conexión; si ya hay otro proveedor contratado, revisar su configuración antes de crear recursos nuevos.

1. Entrar a la [consola de Twilio](https://console.twilio.com/). Si la cuenta es de prueba, registrar como destinatario verificado el teléfono propio que recibirá el SMS. Las pruebas gratuitas solo permiten destinatarios verificados; el lanzamiento al público requiere los requisitos de cuenta de Twilio. [Límites de prueba](https://www.twilio.com/docs/verify/quickstarts).
2. Ir a **Verify → Services**, crear un servicio llamado **LibretApp** y habilitar **SMS**. Establecer **Code length = 6**: el formulario de la app acepta seis dígitos. Mantener **Fraud Guard** activo. [Configuración del servicio](https://www.twilio.com/docs/verify/api/service).
3. En **Verify → Settings → Geo permissions**, permitir SMS a **México (+52)** con monitoreo de fraude. Mantener deshabilitados los destinos que no se atenderán inicialmente. La app permite seleccionar otros países, pero el proveedor rechazará los destinos no habilitados. [Permisos por país](https://www.twilio.com/docs/verify/preventing-toll-fraud/verify-geo-permissions).
4. Identificar **Account SID** (`AC...`), **Auth Token** y el **Service SID** de Verify (`VA...`). El Auth Token debe permanecer en el panel del proveedor y en Supabase. No copiarlo al chat, al repositorio ni a los parámetros de Flutter.

Verify y Programmable Messaging son opciones diferentes: para **Twilio Verify** se usa el servicio `VA...`; no un Messaging Service `MG...` ni el número remitente. La integración está documentada por [Twilio con Supabase](https://www.twilio.com/en-us/blog/developers/community/sms-voting-hookdeck-verify-messaging-supabase).

Revisar el costo vigente antes de habilitar envíos públicos. Verify cobra la verificación y los cargos del canal según destino; no confundir las tarifas publicadas para Estados Unidos con México. No hace falta contratar un número dedicado para seguir la integración estándar de Verify. [Precios y recursos incluidos](https://www.twilio.com/en-us/verify/pricing).

## 3. Conectar el proveedor en Supabase

En **Authentication → Sign In / Providers → Phone** (la sección puede aparecer como **Providers**):

| Campo | Configuración |
| --- | --- |
| Enable Phone provider | Activado |
| SMS Provider | **Twilio Verify** |
| Twilio Account SID | El `AC...` de la cuenta que tiene el servicio |
| Twilio Auth Token | El token secreto de esa misma cuenta |
| Twilio Verify Service SID | El `VA...` del servicio LibretApp |
| Confirmación de teléfono | Exigir código; sin confirmación automática |
| OTP length, si aparece | 6; configurar también 6 en Twilio |
| Intervalo entre solicitudes | Al menos 60 segundos |

Guardar y comprobar que se permiten usuarios nuevos (**Allow new users to sign up**). No dejar números con códigos fijos de prueba en la configuración pública.

Con Verify, Twilio gestiona la validez del código: su valor predeterminado es diez minutos y un reenvío durante ese periodo puede entregar el mismo código. No prometer otro plazo ni que reenviar siempre cambia el código. Revisar también los ajustes de expiración expuestos por Supabase. [Validez en Verify](https://www.twilio.com/docs/verify/api/rate-limits-and-timeouts).

En **Authentication → Rate Limits**, revisar el límite global de SMS y conservar el intervalo de 60 segundos. El temporizador del formulario no sustituye el límite del servidor. Para la primera prueba, conservar límites bajos y anotar los valores elegidos. [Límites de Supabase](https://supabase.com/docs/guides/auth/rate-limits).

La app actual no envía `captchaToken`: activar CAPTCHA obligatorio en Supabase antes de integrar el desafío en Flutter impediría las solicitudes. Su integración y validación deben resolverse antes de abrir el formulario a tráfico público si se adopta esa protección. Supabase recomienda CAPTCHA y límites para controlar abuso y costos. [Protección contra bots](https://supabase.com/docs/guides/auth/auth-captcha).

## 4. Habilitar registros públicos en Twilio

Revisión del 19 de octubre de 2026: la cuenta todavía muestra **Trial**. Se abrió **Upgrade → Create customer profile**, sin aceptar el consentimiento ni enviar documentos. El flujo de la consola exige, en este orden, **Create customer profile**, **Tax information**, **Starting balance** y **Payment details**. El primer formulario muestra consentimiento para el tratamiento de información biométrica por Persona; debe completarlo personalmente el titular, junto con cualquier identificación requerida. No compartir documentos, datos fiscales, tarjeta ni códigos por chat. No se efectuaron cargos ni se activó una recarga automática durante esta revisión.

Para admitir destinatarios sin registrarlos previamente como números de prueba, Twilio exige actualizar la cuenta y tener el perfil principal aprobado. Completar el pago por sí solo no acredita la aprobación del perfil. [Requisitos de Verify](https://www.twilio.com/docs/verify/quickstarts).

1. El titular completa el perfil con su identidad real y el tipo de persona o empresa que corresponda. Si el perfil queda en revisión, esperar el resultado o atender lo que Twilio solicite, sin prometer plazos.
2. El titular completa los datos fiscales, revisa el monto real del saldo inicial y los cargos mostrados, y añade el método de pago. No presuponer una cantidad mínima ni activar recarga automática sin una decisión expresa. Estas acciones requieren intervención del titular en la consola.
3. Comprobar tanto la salida del estado Trial como la aprobación del perfil. Conservar el servicio Verify LibretApp existente y la conexión que ya funciona en Supabase; no recrearlos ni copiar secretos al cliente.
4. Confirmar los países de lanzamiento con el propietario. En **Verify → Settings → Geo permissions**, revisar SMS para esos destinos y usar la opción de monitoreo de fraude con **Fraud Guard Standard**. No habilitar todos los países para resolver una restricción de destinatarios de prueba: son controles distintos. [Permisos geográficos](https://www.twilio.com/docs/verify/preventing-toll-fraud/verify-geo-permissions).
5. Revisar en Supabase los límites reales antes de abrir tráfico público y acordar su capacidad según la demanda y el presupuesto. Como referencia documental, Supabase publica valores predeterminados de 30 SMS por hora y 60 segundos entre solicitudes al mismo usuario; no confundirlos con una lectura de la configuración actual. Mantener el control de reenvío y no activar CAPTCHA obligatorio mientras la app no lo resuelva. [Límites de Auth](https://supabase.com/docs/guides/auth/rate-limits).
6. Con autorización para el destinatario y el gasto, realizar un único registro desde LibretApp con un número que no esté en los destinatarios de prueba. Confirmar recepción, código aceptado, cuenta con teléfono confirmado y apertura del espacio local. La aprobación previa del 4477 no sustituye esta prueba de producción. Si se utiliza el destinatario terminado en 3453, solicitar un código nuevo desde la app después de completar los requisitos, sin reutilizar códigos anteriores.

Pendientes de esta revisión: completar personalmente el perfil, confirmar su aprobación, completar facturación y pago, acordar países y verificar su configuración, revisar límites reales y probar un destinatario nuevo. No anunciar todavía que cualquier usuario puede registrarse. Los registros continúan locales; habilitar Twilio no añade sincronización ni respaldo en la nube.

## 5. Conectar y compilar Android

Desde la carpeta `libretapp`, copiar una sola vez el ejemplo al archivo local ignorado por Git:

```powershell
if (Test-Path -LiteralPath onboarding.dart-define.local.json) {
    throw 'El archivo local ya existe; edítalo sin sobrescribirlo.'
}
Copy-Item onboarding.dart-define.example.json onboarding.dart-define.local.json -ErrorAction Stop
```

Si el archivo local ya existe, editarlo en lugar de sobrescribirlo. Sustituir URL, clave pública, soporte y privacidad. Este archivo se integra al APK: admite únicamente parámetros del cliente. No incluir secretos del proveedor.

Ejecutar en PowerShell 7:

```powershell
pwsh -File tool/check_phone_auth.ps1 -Offline
pwsh -File tool/check_phone_auth.ps1
```

La primera orden revisa el archivo; la segunda hace únicamente una consulta `GET /auth/v1/settings` con la clave pública. Comprueba Phone, altas y confirmación requerida. No envía mensajes, no crea usuarios y no verifica que las credenciales de Twilio sean correctas. El archivo de ejemplo con campos pendientes debe fallar la validación.

Después de que la conexión responda correctamente:

```powershell
flutter build apk --debug --flavor standard --dart-define-from-file=onboarding.dart-define.local.json
```

El APK resultante es `build/app/outputs/flutter-apk/app-standard-debug.apk`. Antes de actualizar una instalación existente, comparar el paquete, el código de versión y el certificado de firma. Una APK debug no actualiza una app firmada con otra clave. Si el teléfono ya tiene una versión release, compilar `--release --flavor standard` con el mismo archivo de parámetros y la firma privada existente; no sustituir sus claves ni desinstalar para forzar la prueba. Instalar mediante `adb -s <dispositivo> install -r <apk>` únicamente cuando la firma coincida y el código de versión sea igual o mayor. La variante `offline` no permite Internet ni autenticación por teléfono. Nube y sincronización siguen deshabilitadas. Para publicar, completar también privacidad y soporte.

## 6. Prueba que confirma el funcionamiento

Con un número propio o autorizado, conexión a Internet y el APK recién compilado:

1. Elegir **Crear cuenta con mi teléfono** o **Perfil → Ajustes → Cuenta → Vincular mi número**. Seleccionar México e introducir diez dígitos nacionales.
2. Solicitar un solo SMS; comprobar que llega. Introducir el código en la app, sin compartirlo en el chat.
3. Confirmar que entra al espacio de cuenta y que el usuario aparece con teléfono confirmado en **Authentication → Users**. Si se vinculó un invitado, revisar que conserve sus animales y fotos.
4. Cerrar y reabrir la app; trabajar sin conexión. Cerrar sesión con conexión y volver a verificar el mismo número para probar el reingreso.
5. Registrar fecha, compilación probada, recepción, verificación y reingreso; no anotar códigos, tokens ni el número completo en documentos compartidos.

Si falla el envío, revisar **Authentication → Logs** y **Twilio → Verify → Logs**. Comprobar primero credenciales de la misma cuenta, servicio `VA...`, destinatario verificado en prueba, país permitido, saldo y límites. No desactivar Fraud Guard para resolver un rechazo sin diagnosticarlo. Si el código no se acepta, verificar longitud de seis dígitos, plazo, número y servicio. Si el botón indica que aún no está disponible, revisar el archivo usado al compilar, las banderas y la variante `standard`.

El acceso se considera operativo únicamente después de recepción y verificación reales. Un diagnóstico correcto, un código fijo de prueba o una respuesta simulada no sustituyen esta prueba.

## Comprobaciones de la preparación local

### Resultado de la prueba física

Tras la actualización mediante ADB, el propietario completó el acceso del número terminado en **4477**. Antes de ejecutar el nuevo envío autorizado, se encontró la cuenta ya verificada en **Perfil → Ajustes → Cuenta**, por lo que el agente no solicitó otro SMS. Se conservó evidencia en `artifacts/onboarding/adb-phone-check/account-confirmed.png`.

La lista **Authentication → Users** todavía mostraba un estado vacío. Para resolver la discrepancia, se ejecutó únicamente esta consulta de lectura en SQL Editor, sin guardar el fragmento ni modificar usuarios:

```sql
select count(*) as cuentas_4477,
       count(*) filter (where phone_confirmed_at is not null) as telefonos_confirmados,
       max(last_sign_in_at) as ultimo_acceso
from auth.users
where right(phone, 4) = '4477';
```

Resultado: **1 cuenta, 1 teléfono confirmado**, con último acceso registrado el 19 de octubre en la zona horaria de México. La captura del resultado está en `artifacts/onboarding/adb-phone-check/supabase-account-confirmed.jpg`. No se consultaron tokens ni códigos. Un reinicio del proceso con `am force-stop` y apertura posterior llevó a Inicio sin pedir acceso. No se cerró sesión; esa prueba y la comprobación del trabajo sin red permanecen pendientes. Los siguientes párrafos describen las etapas anteriores de preparación, no pendientes adicionales de la primera verificación.

El diagnóstico pasó 13 comprobaciones con archivos ficticios y respuestas simuladas: claves públicas actuales y heredadas, rechazo de `service_role` y secretos adicionales, URL insegura, banderas incompatibles, proveedor deshabilitado, altas deshabilitadas, confirmación automática, errores de red sin divulgar la respuesta y campos pendientes del ejemplo. No se consultó un proyecto real ni se enviaron mensajes durante esas comprobaciones.

Se compiló correctamente `artifacts/onboarding/LibretApp-supabase-debug.apk` usando el archivo local del proyecto. Se verificaron paquete `app.libret`, versión `0.1.2+5` y permiso `android.permission.INTERNET`. SHA-256 del APK: `4C01F9F61E50777EF99BDAD4760CFF493E4DF9748DEC03E270EAE3702F4A40C3`. Después de guardar Twilio Verify, el diagnóstico real de Auth terminó con código 0 y confirmó Phone, altas y verificación requerida. El mismo APK ya contiene la configuración pública necesaria; este cambio remoto no requiere recompilarlo. Se comprobó recepción real de un SMS al destinatario autorizado terminado en 4477. Sigue pendiente instalar o abrir este APK en Android, solicitar allí su propio código, verificarlo y comprobar el reingreso. No introducir el código de la prueba externa en una pantalla de la app que todavía no haya solicitado el suyo.

Prueba física del 19 de octubre mediante ADB: el OPPO CPH2123 con Android 12 (API 31) tenía `0.1.3+6`, variante sin permiso de Internet, y solo mostraba invitado y demo. La APK debug anterior tenía menor versión y otro certificado, por lo que no se intentó instalarla. Se compiló el código actual como `standard release`, conservando `0.1.3+6`, los parámetros locales de Supabase y la firma privada existente. Tras comprobar que los certificados coinciden, `adb install -r` terminó en **Success**, sin desinstalar ni limpiar datos. Se comprobó en la interfaz del móvil que aparece **Crear cuenta con mi teléfono** y se abre **Tu cuenta por teléfono**, con México y envío por SMS. APK: `artifacts/onboarding/LibretApp-0.1.3+6-supabase-release.apk`; SHA-256: `99BB0F9ED4B4C86E86E3A2D21C9C6EC68C396C885081E249267BB2E8B98F2490`. El formulario observado contenía el destinatario terminado en 3453; no considerarlo habilitado por esta actualización, pues sigue sujeto a la restricción de Twilio. Queda pendiente completar el SMS y la verificación desde la app con un destinatario autorizado, y después el reingreso. Esta APK es para la prueba local; la compilación no acredita preparación para publicación.
