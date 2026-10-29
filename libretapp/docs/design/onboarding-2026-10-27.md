# Inicio en dos pantallas · 27 de octubre de 2026

## Experiencia

La bienvenida presenta «Cuidar empieza aquí» y dos tarjetas ilustradas con la
misma relevancia: Mascotas y plantas, y Ganado y campo. Al elegir se abre una
vista previa identificada como ficticia y adaptada a esa experiencia.

«Empezar sin cuenta» es la acción principal; «Probar con ejemplos» abre la demo
correspondiente y el teléfono se ofrece como opción secundaria cuando está
configurado. Elegir y entrar sin cuenta requiere dos pulsaciones. El aviso de
almacenamiento local y copia externa permanece visible.

Se conservan los recursos de marca e ilustraciones existentes. La transición
usa un desvanecimiento de 240 ms y se elimina al solicitar movimiento reducido.
El contenido permite desplazamiento con texto ampliado. El panel Inicio y la
autenticación telefónica conservan su funcionamiento.

## Persistencia y demos

- Se conserva `onboarding.page.v2`: `-1` representa la elección y las páginas
  antiguas `0–4` se normalizan al acceso. Una elección pendiente conserva su
  experiencia; sin ella se usa Ganado y campo.
- El callback de ejemplos recibe `AppExperience` y `openDemo` admite esa
  experiencia, usando `complete` por defecto para los consumidores anteriores.
- La demo doméstica contiene Luna (perra), Milo (gato), Mi monstera, Huerto de
  aromáticas y tres actividades para hoy, mañana y pasado mañana. Los IDs son
  estables y la instalación se marca solo al completar todas las escrituras.
- Cada demo utiliza base, preferencias y archivos temporales propios. Volver a
  instalar conserva las ediciones; salir o interrumpir la app descarta el
  espacio. La salida vuelve al acceso con la experiencia elegida.
- Salir de una demo no configura la experiencia del invitado. Al entrar sin
  cuenta se aplica la elección explícita al mismo espacio de invitado; las
  cuentas existentes conservan su propia experiencia.
- El modo queda fijo durante cada demo. Las notificaciones se cancelan al
  cambiar de espacio y las lecturas anteriores se invalidan. Las demos no
  solicitan permisos ni programan sus actividades como alarmas reales.
- No se añaden dependencias, tablas ni cambios al formato de respaldo.

## Evidencia local

- 39 pruebas de interfaz, progreso antiguo, navegación, arranque y capturas
  aprobadas.
- 53 pruebas de regresión de espacios, demo doméstica, mascotas, acceso
  telefónico, preferencias y notificaciones aprobadas.
- Tras añadir dos escenarios del selector de demos y reforzar el caso de
  avisos futuros, las 11 pruebas de preferencias y notificaciones volvieron a
  pasar. Estas tandas comparten pruebas; sus conteos no se suman.
- Una tanda posterior de 40 pruebas confirmó el ajuste de espacio y la elección
  explícita del invitado tras alternar demos. Las capturas equivalentes al OPPO
  comprueban además que el aviso de respaldo cabe completo sin desplazamiento.
- Análisis estático de los 12 archivos revisados: sin incidencias.
- Compilación `standard release` con configuración telefónica y firma
  existentes. Se aplicó únicamente al proceso de compilación la solución local
  de Java para conexiones loopback ya documentada en el proyecto.
- APK para Android arm64: `artifacts/onboarding/LibretApp-inicio-2026-10-27.apk`. Actualización del
  OPPO CPH2123 por ADB con `install -r`, comprobando antes la coincidencia de
  certificados. Se conservaron los datos de la instalación.

Capturas reproducibles con
`flutter test --no-pub tool/preview_onboarding_test.dart`:

- `artifacts/onboarding/bienvenida.png`
- `artifacts/onboarding/mascotas.png`
- `artifacts/onboarding/ganado.png`
- Las tres variantes de tema oscuro usan el sufijo `-oscuro`.

La prueba de interfaz cubre pantalla de 320 × 568 con texto al 200 %, ambos
temas, objetivos táctiles, etiquetas accesibles y movimiento reducido.

La herramienta de captura Android acepta `--package app.libret` para verificar
que la app siga en primer plano antes de leer o interactuar. Las capturas del
OPPO se guardan en `artifacts/onboarding/oppo/`.

## Comprobaciones físicas

En el OPPO CPH2123 se revisaron la bienvenida y los accesos de ambas
experiencias. La demo doméstica abrió Inicio, Mascotas, Agenda, Plantas y Perfil
con Luna, Milo, Mi monstera y Huerto de aromáticas. La demo ganadera conservó
Rancho El Mezquite y su navegación completa. Ambas mostraron el rótulo de datos
ficticios y el botón de salida.

Salir de cada demo volvió al acceso de la experiencia elegida. Forzar el cierre
durante la demo ganadera y abrir de nuevo devolvió al acceso, descartando el
espacio temporal. La consulta de alarmas durante la demo doméstica no encontró
alarmas de `app.libret`. No se solicitaron códigos SMS durante estas pruebas.

Con el APK final se comprobaron los dos accesos sin cuenta: cada uno abrió su
Inicio correspondiente en el mismo espacio real, vacío y sin los ejemplos de
las demos. El aviso de respaldo se leyó completo en la pantalla del OPPO. La
consulta de errores de ejecución del proceso final no detectó errores.

Capturas finales: `oppo/bienvenida-final.png`, `oppo/mascotas-acceso-final.png`,
`oppo/ganado-acceso-final.png`, `oppo/mascotas-invitado.png` y
`oppo/ganado-invitado.png`, dentro de `artifacts/onboarding/`.

SHA-256 del APK final:
`E523B582460C0C75CB8CDDD14E804415F6FD7E89B39E7B307BB88AEAF5CA38CD`.
