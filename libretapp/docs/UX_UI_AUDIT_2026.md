# Auditoría UX/UI de LibretApp

Fecha de actualización: 2026-08-25

## Dirección de producto

La prioridad es el trabajo de rancho en Android portrait, con una mano, poca conectividad y captura rápida. Se conserva la identidad verde/ámbar; el mayor retorno está en adoptar el design system existente de manera uniforme, no en cambiar la marca.

## Cambios implementados en esta iteración

- Se añadió `AppFormScaffold` para formularios de pantalla completa, con `Form` opcional, scroll con teclado, safe area, estado de carga, acción Guardar y acción Cancelar.
- Se añadió `AppDateField`, con formato localizado, target accesible, validación inline, límites de fecha, opción de borrar y protección explícita contra perder una fecha cuando el selector se cancela.
- Se consolidó la adopción de `AppTextField`, `AppSelectField`, `AppButton`, `AppIconButton`, `AppEmptyState` y `AppLoadingIndicator`.
- Se migraron las ocho familias de registros de animales: peso, sanitario, producción, reproducción, comercial, movimiento, costo y salud masiva.
- Se migraron los formularios de ingreso y gasto general de Finanzas.
- Se migraron los formularios reutilizados de Agenda, incluyendo asignación, animales/lotes, ubicación, fecha, recurrencia, checklist y acciones.
- Se migraron los formularios principales de ubicaciones, cultivos e inventario.
- Agenda ahora presenta el error con el mismo patrón de estado vacío y reintento, y sus acciones de búsqueda, navegación y cambio de vista respetan targets compartidos.
- Se añadieron textos localizados para fechas, acciones y Finanzas en español e inglés.

## Matriz de auditoría por superficie

| Superficie | Hallazgo principal | Acción aplicada | Siguiente acción |
| --- | --- | --- | --- |
| Onboarding | Debe priorizar contexto, permisos y funcionamiento local | Mantener identidad y ruta existente | Añadir demo offline y recuperación de sesión |
| Inicio | Es el punto de entrada de captura | Usar acciones compartidas como base | Diseñar modo “captura rápida” P0 |
| Directorio / animales | Muchos registros paralelos y campos inconsistentes | Ocho formularios migrados | Unificar registro rápido desde detalle y acciones masivas |
| Lotes | Contexto útil, pero puede perderse al crear registros | Mantener rutas actuales | Persistir lote/animal/ubicación como contexto en cada formulario |
| Ubicaciones | Formularios complejos con categorías y atributos adaptativos | Campos, fechas y acciones principales migrados | Añadir mapas/GPS y trazabilidad de movimientos |
| Agenda | Búsqueda y acciones tenían controles propios | Búsqueda, estados, navegación y formulario migrados | Recordatorios locales, notificaciones y evidencia fotográfica |
| Registros | Era la mayor duplicación de formularios | Formulario, validación, fecha y guardado estandarizados | Eliminar rutas paralelas que capturan el mismo evento |
| Finanzas | Ingreso y gasto repetían layout y validación manual | Ambos migrados a scaffold y campos compartidos | Categorías configurables, adjuntos y conciliación |
| Reportes | Requiere jerarquía clara con Registro y Finanzas | Mantener módulo independiente | Añadir filtros globales, exportación contextual y comparativos |
| Perfil | Ya concentra ajustes y backups | Mantener como centro de backup y preferencias | Mostrar estado de backup/sincronización en contexto |
| Biblioteca | Es valiosa como ayuda contextual | Mantener acceso desde perfil y registros | Enlazar cada recomendación a una acción del formulario |
| Exportación | Tiene cobertura de prueba existente | No se altera el contrato | Añadir exportación incremental y filtros guardados |

## Pendientes priorizados

### P0 — captura y confianza operativa

1. Modo de captura rápida desde Inicio, detalle de animal, lote y ubicación.
2. Acciones masivas para salud, movimientos, tratamientos y asignación de tareas.
3. Indicador persistente de datos locales, pendientes de sincronizar y último backup.
4. Búsqueda y filtros globales con historial reciente.
5. Pruebas Android portrait en 320–412 dp, text scaling 1.0–2.0, modo oscuro, teclado abierto, sin conexión y guardado fallido.

### P1 — operación de campo

1. Mapas, GPS, geocercas y captura de ubicación al mover animales o lotes.
2. Recordatorios locales y notificaciones push con snooze y repetición.
3. Evidencia fotográfica ampliada para animales, tratamientos, cultivos, equipo y tareas.
4. Trazabilidad de movimientos: origen, destino, responsable, fecha, evidencia y reversión.
5. Inventario de alimento y medicinas: consumos, mínimos, lotes, caducidad y alertas.

### P2 — escala, integración y México

1. Usuarios, roles, permisos, multi-rancho y sincronización multi-dispositivo.
2. RFID, aretes electrónicos, básculas Bluetooth y lectores.
3. Módulos mexicanos para SINIIGA, SENASICA, movilización y trazabilidad nacional.
4. Clima, lluvia, mantenimiento de equipo y planificación de pastoreo.

## Criterios de aceptación de UI

- Todo formulario usa `Form` cuando tiene validación y muestra errores junto al campo.
- Guardar queda deshabilitado durante la operación y muestra progreso sin cerrar antes de confirmar.
- Cancelar cierra sin mutar datos; cancelar un selector de fecha conserva el valor anterior.
- Acciones principales, secundarias, terciarias y destructivas usan `AppButton`; iconos usan `AppIconButton` con tooltip.
- Los controles normales tienen al menos 48 px; los compactos solo se usan en toolbars o chips secundarios.
- Loading, vacío, error y reintento usan patrones compartidos.
- Las pantallas respetan los tokens de `docs/DESIGN_SYSTEM.md` y se verifican con texto ampliado y modo oscuro.

## Benchmarking y oportunidades

- [AgriWebb](https://www.agriwebb.com/us/our-product/): mapas, GPS, fotos, tareas, notificaciones, roles, pastoreo y costos. Oportunidad: conectar ubicación con tarea y evidencia en una sola captura.
- [Farmbrite](https://www.farmbrite.com/): ganado, cultivos, tareas recurrentes, inventario, contabilidad, mapas, clima y reportes. Oportunidad: hacer visible el flujo transversal animal → inventario → finanzas.
- [Ranchr](https://ranchr.com/features/): offline, acciones masivas, embarazo, fotografías, reportes e importación. Oportunidad: que el modo offline sea una promesa visible y medible.
- [CattleMax](https://www.cattlemax.com/): genealogía, reproducción, partos, pasturas, mantenimiento, finanzas e integraciones de hardware. Oportunidad: profundizar trazabilidad reproductiva y conectar básculas/aretes.
- [AgroTrack México](https://agrotrack.com.mx/), [HATOS.ai](https://hatos.ai/) y [cow.mx](https://cow.mx/): español mexicano, SINIIGA, operación offline, WhatsApp y trazabilidad nacional. Oportunidad: diferenciación local con formatos y exportaciones mexicanas.

La oportunidad de LibretApp es combinar su cobertura multiespecie, biblioteca contextual, agenda, ubicaciones y finanzas con una captura de campo más rápida y una capa mexicana de trazabilidad.

## Capturas y QA visual

La matriz de captura recomendada es: Android portrait, claro/oscuro, texto 1.0x/1.3x/2.0x; por cada superficie se deben capturar datos, vacío, carga, error, teclado abierto, sin conexión y guardado fallido. En esta iteración el ejecutable Windows abrió, pero el proveedor de captura visual falló con `SetIsBorderRequired`; por eso las capturas de referencia deben repetirse en un emulador Android o en un entorno de captura compatible antes de cerrar la auditoría visual.

## Verificación realizada

- `flutter analyze` sobre los componentes y superficies modificadas: sin errores; solo se corrigieron imports e infos de estilo durante la iteración.
- Suite enfocada de widgets, registros, ubicaciones y exportación: 23 pruebas pasan.
- La compilación Web se verificó con Drift/SQLite WASM y el service worker; el escaneo Wasm aún informa imports alternativos nativos de Isar/FFI, aunque el bundle dart2js termina correctamente.
