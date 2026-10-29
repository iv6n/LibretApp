# Ficha y declaraciones: borrador para revisión

No enviar a Play hasta validar servicios, titular y paquete final. País inicial:
México. Precio: gratuita. Identidad Android: `app.libret`. Nombre de producto:
LibretApp. Responsable público y correo: pendientes; no reutilizar un contacto
de ejemplo ni el correo de la cuenta que aloja el sitio sin confirmación.

## Textos propuestos

Descripción breve:

> Tu libreta de campo: animales, actividades y respaldos bajo tu control.

Descripción completa, sujeta a la aceptación de las funciones conectadas:

> Lleva los registros de tu rancho en una libreta de campo para Android.
> Consulta tus animales, anota actividades, revisa ingresos y gastos y conserva
> fotografías junto a tus registros.
>
> Puedes empezar como invitado sin crear una cuenta o explorar una demo con
> datos ficticios. Los espacios se mantienen separados.
>
> Con una cuenta verificada por SMS a un teléfono mexicano puedes guardar y
> restaurar respaldos completos. Elige una copia manual o activa respaldos
> automáticos cada 24 horas, por Wi-Fi y con batería suficiente. Android puede
> aplazarlos. Se conservan hasta cinco copias verificadas por cuenta, de hasta
> 100 MiB cada una. Al restaurar eliges Fusionar o Reemplazar.
>
> Tu cuenta no sincroniza continuamente los teléfonos. Para llevar los registros
> a otro equipo necesitas restaurar una copia. También puedes exportar un
> respaldo completo desde Ajustes y guardarlo donde prefieras.
>
> Puedes eliminar tu cuenta desde Ajustes o solicitarlo en nuestra web con
> verificación SMS reciente. Los archivos exportados y los datos de otros
> teléfonos se borran desde sus respectivos destinos.

## Recursos

- `assets/icon-512.png`: identidad aprobada, opaca, 512×512.
- `assets/feature-graphic-1024x500.png`: gráfico de funciones, 1024×500.
- Capturas finales: pendientes. Capturar el candidato configurado, conservando
  hash del AAB/APK, dispositivo, versión, flavor y revisión de configuración.
  Usar datos ficticios y teléfonos de ensayo autorizados. Propuesta: Inicio,
  Directorio, perfil/historial, Registro, Finanzas y Copias en la nube con un
  respaldo realmente verificado. No presentar resultados simulados como reales.

## Seguridad de datos: inventario para completar en Console

Validar cada categoría contra el archivo de respaldo y el tráfico del proyecto
de ensayo; esta tabla es preparación y no una declaración enviada.

Referencia: [tipos y finalidades de datos de Google Play](https://support.google.com/googleplay/android-developer/answer/10787469).

| Información | Tratamiento previsto | Finalidad/condición |
| --- | --- | --- |
| Teléfono | Supabase Auth y Twilio | Identificación, SMS y confirmación sensible; cuenta opcional |
| Identificador de usuario y sesión | Supabase; sesión segura local | Gestión de cuenta y aislamiento de respaldos |
| Nombres y otros datos de perfil/contactos | Local; pueden incluirse en el respaldo | Contenido que introduce el usuario; revisar todos los campos exportados |
| Fotografías | Local; Storage al respaldar | Contenido del usuario, opcional |
| Registros y notas del rancho | Local; Storage al respaldar | Función principal y recuperación |
| Ingresos/gastos y otros importes | Local; pueden incluirse en el respaldo | Revisar categoría «Otra información financiera» según los datos reales |
| Coordenadas manuales de ubicaciones | Pueden incluirse en el respaldo | Revisar «Ubicación precisa» aunque no exista permiso GPS |
| Red/CAPTCHA y registros técnicos de proveedores | Auth, Twilio y Turnstile según configuración | Seguridad, entrega y prevención de abuso; confirmar registros y retención |

No declarar «no se recopilan datos» para la versión conectada. Verificar la
distinción de Play entre proveedores de servicio y datos compartidos; no asumir
que todo proveedor constituye venta o publicidad. Confirmar HTTPS, eliminación,
obligatoriedad por función y retención contra la configuración real. No marcar
pagos o anuncios como funciones de esta entrega.

## Pasos externos del titular

Consultar mayor versionCode, verificar certificado de actualización y Play App
Signing, identificar tipo/antigüedad de cuenta y sus requisitos vigentes. Completar
clasificación, audiencia, privacidad, seguridad de datos, eliminación, acceso del
revisor e informe previo al lanzamiento. Distribuir primero en pruebas internas.
Si la cuenta requiere pruebas cerradas u otra validación, cumplir lo que indique
Console; no inferir exenciones por una denominación informal de la cuenta.

Los mecanismos de cuenta aún no están activos en el sitio publicado de
preparación. Sus enlaces no deben registrarse como una eliminación funcional
hasta completar responsable/correo, configuración de ensayo y pruebas app/web.
