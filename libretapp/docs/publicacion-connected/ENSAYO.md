# Entrega conectada: ensayo y salida a Google Play

Fecha: 22 de octubre de 2026. Mantener `app.libret`, esquema 11 y las bases
existentes. El desarrollo conserva el árbol local del 19 de octubre. No se han
aplicado migraciones a un proyecto remoto ni habilitado envíos facturables.

## Código preparado

- Flavors `offline`, `standard` interno y `connected`. El público conectado
  requiere API 28 y apunta a API 36; excluye GPS/Bluetooth y conserva Internet.
- Controles separados `LIBRETAPP_ENABLE_PHONE_AUTH`,
  `LIBRETAPP_ENABLE_CLOUD_BACKUP` y `LIBRETAPP_ENABLE_SYNC`. La sincronización
  queda inhabilitada en toda compilación pública, aunque se intente activarla.
- Una sesión Supabase en almacenamiento seguro para teléfono y copias. El
  recorrido público no ofrece correo. Toda operación de respaldo vuelve a
  comprobar usuario, teléfono confirmado y espacio activo persistido.
- Subidas reservadas antes de Storage; conciliación de respuestas perdidas,
  SHA-256, máximo 100 MiB y conservación de cinco copias verificadas. Los
  archivos incompletos se limpian en una operación posterior tras 24 horas.
  La limpieza es recuperable y puede dejar más de cinco copias temporalmente
  si falla: comprobar retención también en el ensayo.
- Restauración requiere Fusionar/Reemplazar y vuelve a componer el espacio.
- WorkManager diario, opt-in por cuenta, red sin medición más comprobación de
  Wi-Fi, batería suficiente, revocación de consentimiento y cancelación al salir.
  El cliente HTTP de Storage aborta si detecta pérdida de Wi-Fi. La entrega
  requiere probar la transición real de Wi-Fi a datos antes de aprobarla.
- Bloqueo compartido por archivo; Android usa `flock` para coordinar motores
  Flutter distintos. El trabajo mantiene el bloqueo desde apertura hasta cierre
  de su base. Cierre de sesión, importación desde Ajustes, recuperación mediante
  el gestor y eliminación participan en ese bloqueo.
- Eliminación con exportación voluntaria, SMS reciente, destino obtenido de la
  sesión y marca RLS persistente. Reintentos de la misma sesión y worker de
  recuperación del servidor. Un recibo local permite reanudar el borrado tras
  un cierre del proceso cuando la eliminación remota ya fue confirmada.
- Reportes usa tarjetas de altura natural y oculta reportes detallados pendientes.

## Proyecto existente identificado

El historial del 19 de octubre identifica el proyecto LibretApp
`ylbmwsgaavonqmwhdpci` y una cuenta de prueba de Twilio **Verify**, con un acceso
físico confirmado. Esa evidencia corresponde al flujo anterior; no acredita el
hook nuevo, la caducidad de cinco minutos ni destinatarios públicos. No se ha
modificado su proveedor ni reutilizado su sesión como aprobación de la entrega.

El hook preparado envía el código generado por Supabase mediante **Programmable
Messaging**, con `MessagingServiceSid` **MG...**. El servicio Verify existente
**VA...** no es intercambiable con ese identificador. La migración debe ensayarse
en un proyecto separado, revisar el proveedor de verificación de Auth para que
valide el código de Supabase y no un código externo de Verify, y validar el costo
real de ese canal antes de activar facturación. No cambiar el proyecto existente
hasta resolver esa prueba y preservar su cuenta y datos. El archivo local sigue
ignorado por Git y no se imprimen sus credenciales.

## Preparar un proyecto de ensayo

1. Confirmar con el titular el identificador de **ensayo**. No asumir que la
   configuración local anterior es de ensayo. Hacer una copia del proyecto
   existente y ensayar las migraciones sobre ella antes de aplicarlas al real.
2. Ejecutar `supabase start` y `supabase test db` en Docker operativo, o el job
   `supabase-security` de CI. Incluye aislamiento, revocación con JWT anterior y
   cuotas. Un workflow escrito no acredita una ejecución aprobada.
3. Revisar primero datos históricos incompatibles con las nuevas restricciones
   de tamaño, digest y ruta. Las restricciones `NOT VALID` protegen escrituras
   nuevas sin modificar filas antiguas. No ejecutar `VALIDATE CONSTRAINT` hasta
   diagnosticar esas filas y conservar sus objetos.
4. En Auth: teléfono habilitado, seis dígitos, vencimiento 300 s, espera 60 s,
   Turnstile obligatorio. El proyecto público no debe permitir OTP por correo:
   la reverificación sensible exige proveedor único `phone`, sin correo asociado,
   y un evento OTP reciente. Las cuentas internas con proveedores mezclados
   necesitan una migración revisada antes de habilitar este recorrido público.
5. Registrar `send-sms` como hook HTTP **firmado** de Supabase. El hook sustituye
   el proveedor incorporado; no configurar un segundo emisor que eluda cuotas.
   Desplegar Functions con verificación JWT de plataforma deshabilitada como
   declara `config.toml`: cada endpoint implementa su propia verificación.
6. Configurar secretos en servidor: `SEND_SMS_HOOK_SECRET`, `SMS_QUOTA_PEPPER`,
   `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_MESSAGING_SERVICE_SID`,
   `DELETION_WORKER_SECRET`, `PUBLIC_SITE_ORIGIN`. URL/service role se obtienen
   del entorno de Functions. No incluir ninguno de esos secretos en Dart,
   `dist/config.js`, archivos de candidatos, logs ni Git.
7. Mantener `SMS_BILLING_ENABLED=false`. Antes de cambiarlo: validar con la
   cuenta real los precios a México, segmentos del mensaje, cargos adicionales,
   número/remitente, saldo, límites de prueba y permisos geográficos +52. Las
   cuotas son topes de intentos, no una estimación monetaria. Los intentos con
   respuesta ambigua consumen cuota y no se reenvían automáticamente a Twilio.
8. Vigilar `sms_quota_alerts` y el aviso de servidor al 80 %: 4/5 por número,
   40/50 diarios y 240/300 mensuales. Las cuotas usan America/Mexico_City y una
   reserva SQL serializada. Conectar el monitor operativo elegido por el titular.
   Actualmente el aviso se persiste y registra; no se ha configurado un destino
   de notificación externo. El worker de recuperación ejecuta también `prune_sms_usage` para purgar huellas
   mayores de 32 días aunque no haya tráfico SMS. La reserva realiza además purga oportunista.
9. Programar `resume-deletions` desde un scheduler de servidor cada 15 minutos,
   con su secreto dedicado; no distribuirlo a la app. Reintenta marcas pendientes
   incluso si Auth ya se eliminó o la sesión del solicitante expiró. Verificar
   respuestas de Auth y residuos de Storage antes de marcar completo.
10. Probar una cuenta pública sin datos de sincronización antiguos. Para datos
    internos existentes, revisar antes las fincas compartidas y sus registros:
    el worker elimina fincas de propietario único y retira la atribución en las
    compartidas. Nunca habilitarlo sobre el proyecto existente sin ese ensayo.

## Sitio y datos del titular

Sitio público: <https://libretapp-mexico.delcarmenmariscos.chatgpt.site>.
Tiene `/privacidad/`, `/eliminar-cuenta/`, `/soporte/` y `/captcha/`, sin sesión
de ChatGPT. Fuente independiente bajo `sites/libretapp-public`; identidad Sites
en su `.openai/hosting.json`.

Está publicado como **preparación**: faltan responsable y correo reales y el
formulario conectado está desactivado. No es aún una política o vía de
eliminación operativa para declarar cumplimiento en Play. Completar configuración
pública, actualizar el texto de borrador, configurar CORS/Turnstile y verificar
el flujo sin reinstalar la app. El navegador conserva la sesión de eliminación
solo en memoria. La web no puede borrar archivos locales de otros teléfonos ni
exportaciones; explicar ese límite expresamente al titular y en la versión final.

## Candidatos y evidencia

Ejemplo de QA sin servicios activados:

```powershell
python tool/build_android_candidate.py --mode qa --flavor connected --out artifacts/connected-qa
python tool/build_android_candidate.py --mode qa --flavor offline --out artifacts/offline-qa
```

Usar el Python disponible en el entorno si `python` apunta al alias de Microsoft
Store. El script admite `--config` con URL/clave pública Supabase y URL CAPTCHA;
rechaza `service_role`, claves secretas y campos inesperados. Nunca subir una
configuración real al repositorio. Conservar también la configuración de Auth,
hooks y revisión de migraciones de ensayo como evidencia del despliegue servidor.

El generador vincula fuente, flavor, configuración y SHA-256 del AAB. QA usa firma
debug desechable y no lee la clave privada. `--mode store` exige datos reales,
mayor versionCode consultado en Console y evidencia vigente. Un AAB firmado para
aceptación sigue con `readyForStore=false` hasta aceptar el hash de ese artefacto.
La presencia de la firma y alineación ELF no reemplaza la ejecución en 16 KB,
`zipalign -P 16` del APK, bundletool ni la comparación del certificado histórico.

No usar los paquetes del 19 de octubre como evidencia del candidato conectado.
El icono aprobado y gráfico 1024×500 están en `assets/`; las capturas de tienda
deben provenir del candidato configurado final y están pendientes. No presentar
renders de widgets ni capturas de otro AAB como capturas del candidato final.

## Aceptación pendiente

Dos cuentas reales de ensayo; SMS correcto/incorrecto/vencido, CAPTCHA, reenvío y
cuotas; recuperación de sesión; copia/restauración con fotos entre dos teléfonos;
red interrumpida, retención y archivos incompletos; automático con app cerrada,
batería baja, cambio de red, reinicio y cierre de sesión; restauración simultánea;
eliminación desde app/web, fallo parcial y reintentos. Validar Android 28 y 36/16 KB,
teléfono físico, TalkBack, permisos rechazados, texto 200 %, teclado y mil animales.
Un test simulado o una prueba del piloto anterior no acredita estos escenarios.

Entradas pendientes del titular: nombre público, correo de soporte, proyecto de
ensayo, configuración segura Twilio, acceso a Play Console, tipo/antigüedad de
cuenta, mayor versionCode y certificados de actualización/Play App Signing.
Preparar prueba interna primero; México como único país inicial. Completar las
declaraciones de privacidad, seguridad de datos, clasificación, audiencia, acceso
del revisor y el informe previo al lanzamiento según la cuenta indicada.

Referencias oficiales:
[teléfono Supabase](https://supabase.com/docs/guides/auth/phone-login),
[hook SMS](https://supabase.com/docs/guides/auth/auth-hooks/send-sms-hook),
[WorkManager](https://developer.android.com/develop/background-work/background-tasks/persistent/getting-started/define-work),
[eliminación en Play](https://support.google.com/googleplay/android-developer/answer/13327111).


## Instalación nativa y conservación de datos

La herramienta Flutter puede desinstalar automáticamente una app cuando detecta
un certificado diferente, incluso al pasar `--no-uninstall`. Se observó ese
comportamiento en el emulador de QA de 16 KB: no se considera prueba de
actualización con conservación de datos. No ejecutar ese flujo sobre un teléfono
con datos reales. Antes de actualizarlo, comparar certificados del paquete
instalado y del candidato, usar el certificado de actualización correcto y
confirmar el resultado sin desinstalar. Los recorridos de integración se limitan
a emuladores o equipos dedicados con datos ficticios. La aceptación de la firma
histórica y de la actualización real permanece pendiente.
