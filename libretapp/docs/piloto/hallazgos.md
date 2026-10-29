# Hallazgos del directorio y del candidato offline

P0: pérdida de datos o flujo principal inutilizable. P1: error funcional/accesibilidad. P2: presentación/comodidad. Una validación pendiente no se registra como defecto sin reproducción.

| ID | Prioridad | Pantalla / reproducción | Corrección y aceptación | Evidencia |
|---|---|---|---|---|
| D01 | P1 | Perfil y lista: propósito lechero, dos turnos en un día; promedio de leche discrepante o peso estimado como medido | Cálculo compartido suma turnos por día; peso procede de registros; sin medición no hay cero inventado | `animales_list_controller_snapshot_test`, `animal_record_actions_test` |
| D02 | P1 | Perfil: animal vendido/fallecido; abrir Registrar o añadir cuidado | Sin operaciones nuevas en el perfil; consulta e historial conservados | Políticas por estado y 48 casos del perfil |
| D03 | P1 | Perfil: macho/no reproductivo o especie sin ordeña; abrir acciones | Menú aplica especie, sexo, propósito y lactancia; ordeña solo cuando corresponde | `animal_record_actions_test`; Android `animal-menu-registros.png` |
| D04 | P1 | Regresar al listado después de pesar o mover animal; indicador queda en caché | Invalida caché y resultados en vuelo; recarga ubicación al regresar | Dos pruebas de invalidación en `animales_list_controller_snapshot_test` |
| D05 | P1 | Cultivo/ubicación: simular escritura fallida al guardar actividad; formulario se cerraba antes del resultado | Captura conservada, error visible, reintento sin envío duplicado; cerrar solo tras persistir | `record_save_scope_test`, `cultivation_detail_page_test` |
| D06 | P1 | Cuidado: falla de escritura; captura perdida o confirmación anticipada | Guardado dentro del diálogo, bloqueo de envíos y conservación de notas | `care_tab_test`; revisión del flujo y bloqueo |
| D07 | P1 | Lote/asignación: respuesta inmediata antes de escuchar estado del BLoC | Escuchar primer estado sin carga; evitar esperar otra emisión que nunca llega; formulario ocupado | `info_tab_dispatch_and_await_test`; revisión de LoteForm y LoteDetail |
| D08 | P1 | Cultivo/ubicación: stream emite error; carga infinita o «no encontrado» | Mensaje claro y Reintentar; recuperación de stream | `cultivation_detail_page_test`, `location_detail_cubit_test` |
| D09 | P1 | Ajustes: seleccionar oscuro y volver al perfil; app forzaba claro | ThemeBloc determina el modo y mantiene preferencia | Capturas claro/oscuro; prueba del tema existente |
| D10 | P1 | Perfil 320 dp, texto 2×: títulos de Cuidados/Genealogía y acciones laterales desbordan | Títulos flexibles, acciones debajo, botones legibles, paneles con separación inferior | 48 casos sin excepciones; antes/después en galería |
| D11 | P1 | Cosecha 320 dp, texto 2×, teclado: fila de calidad y desplegables desbordan | Calidad con Wrap y desplegables expandibles; formulario desplazable | Cuatro formularios con texto doble y teclado en `cultivation_detail_page_test` |
| D12 | P1 | Android: importar respaldo y volver a Ajustes; indicador de ocupado seguía activo; perfil de rancho anterior | Liberar ocupado en finally y recargar PerfilBloc después de persistir | Capturas de importación/ajustes del build final |
| D13 | P1 | Android: Ubicaciones muestra 0/15; detalle del mismo Corral de Aves muestra 2/15 | Esperar cálculo antes de finalizar evento; escuchar cambios de animales sin editar ubicación | Android antes/final; prueba de carga, movimiento y exclusión de vendido en `ubicaciones_bloc_test` |
| D14 | P1 | AAB con Isar 3.1: segmentos ELF de 4 KB | Isar Community 3.3.2, mismo esquema; todo ELF de 64 bits alineado ≥16 KB | Base real anterior abre/escribe/reabre; `release-verification.json` |
| D15 | P2 | Perfil sin foto o lote/ubicación asignados | Alternativa accesible; zoom; nombres y enlaces; cabecera mantiene identidad al desplazar | 16 comparaciones; Android Nancy y navegación conectada |
| D16 | P2 | Lote: fecha de creación aparece como milisegundos; acción «Eliminar» cierra lote | Fecha dd/MM/yyyy; «Cerrar lote» explica conservación de historial | `lote-detalle.png` antes; build final y revisión |
| D17 | P2 | Ubicación offline: «GPS pendiente» invita a integración oculta | «Sin coordenadas» / «Coordenadas guardadas», coherente con datos manuales | Captura ubicación antes/final |
| D18 | P1 | Formularios de salud/reproducción/movimiento a 320 dp y texto 2×: título del panel de consejos desborda | Título flexible; los ocho formularios completos se desplazan sin excepciones | 16 pruebas de `animal_record_forms_layout_test` |
| D19 | P1 | Movimiento en offline: aparecía la opción de capturar GPS aunque el manifiesto la restringe | Opción y captura protegidas por ReleaseFeatures | Prueba con variante offline y recorrido nativo |
| D20 | P1 | Listado oscuro: etiquetas casi ilegibles; nombre/ubicación extensos desbordan a 320 dp y 2× | Texto usa onSurface en oscuro; nombre y ubicación flexibles; acceso a ubicación de 48 dp | `animal_card_layout_test`; captura final de listado |

Todos los defectos de esta tabla tienen corrección en el candidato. Las pruebas específicas se complementan con la suite completa; ninguna columna implica un recorrido nativo que no figure en la matriz.

Pendientes de aceptación: TalkBack completo, permisos rechazados en teléfono físico, recorridos exhaustivos de formularios/diálogos señalados en la matriz, rendimiento de dibujo con 1,000 animales en Android y datos públicos del titular. Registrar nuevos defectos aquí con pasos, captura, prioridad y criterio antes de aceptar el piloto.
