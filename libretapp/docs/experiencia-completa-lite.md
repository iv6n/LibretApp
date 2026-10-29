# Experiencias Completa y Lite

La aplicación usa los mismos repositorios y la misma base de datos en ambos
modos. `AppExperienceController` guarda `experience.mode.v1` por espacio de
trabajo. Una instalación nueva elige el modo antes de la bienvenida; la
selección pendiente queda en una clave global hasta abrir el espacio. Una
cuenta existente conserva su propia selección. Si no existe preferencia,
el modo es Completa. La demo ganadera siempre abre en Completa.

Lite muestra perros, gatos, plantas individuales y huertos, además de fechas
personales o relacionadas solo con esas fichas. Los registros ocultos siguen
guardados y se cuentan en Inicio. Cambiar a Completa los vuelve a mostrar.
La edición Lite lee la ficha más reciente y modifica solo los campos visibles.

Una mascota sin edad usa `ageMonths = -1` y `BirthDatePrecision.unknown`;
`birthDate` tiene un valor interno de compatibilidad con el esquema Isar
existente. La interfaz, el DTO y la exportación Excel muestran el dato vacío
o «Sin dato». `Sex.unknown` representa sexo no informado. Cualquier cálculo
nuevo sobre edad debe comprobar `animal.hasKnownAge` primero.

Cada toma de un medicamento es una `AgendaEntry` independiente con `planId`
compartido. Confirmar una toma cambia solo su entrada. Las indicaciones y
horarios los escribe el usuario; no se calculan pautas médicas. El respaldo
existente incluye animales, historiales, agenda y cultivos. La preferencia de
experiencia es local y no se importa desde un respaldo.

En Android, `LiteNotificationService` sincroniza las fechas Lite pendientes
con `AlarmManager`. Se usa una alarma exacta cuando Android concede el acceso
y `setAndAllowWhileIdle` como alternativa aproximada. Al volver desde los
ajustes del sistema, al cambiar de espacio y tras reiniciar el teléfono se
reprograman los avisos. Completar una toma en la Agenda compartida retira su
aviso.

## Verificación

- Pruebas Flutter: primer arranque, espacios con modos distintos, cuenta
  existente, demo, alta mínima, edición que conserva campos ocultos, filtro
  de tareas mixtas, vistas Lite, sincronización de avisos y restauración de
  mascota, ganado, salud, agenda y plantas.
- `dart analyze lib` sin errores.
- La compilación APK no pudo llegar a compilar Kotlin en este entorno:
  Gradle falló al crear una conexión loopback local. Debe ejecutarse
  `flutter build apk --debug --no-pub` en un entorno Android con Gradle
  funcional y probar en dispositivo los permisos, reinicio y entrega de
  alarmas exactas y aproximadas.
