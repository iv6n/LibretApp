# Auditoría de datos y backend — 18 de octubre de 2026

Árbol local de `feature/ui-polish-design-system`, base `f5a12b5`, con cambios sin confirmar. App `0.1.2+5`, respaldo esquema 10. La primera publicación solicitada es Google Play. Se distingue la persistencia Android del piloto `offline` de los adaptadores de nube, web y módulos internos.

**Hay defectos reproducidos que impiden recomendar producción con datos reales.** No hace falta añadir un servidor para publicar el producto local; primero hay que cerrar integridad, recuperación y los recorridos de escritura existentes.

## Defectos del producto Android local

### D01 · P0 · La importación antigua puede borrar datos y quedar a medias

`lib/core/services/backup_service_native.dart:730` limpia animales y lotes para reemplazar un JSON antiguo, y después guarda animales uno por uno en operaciones independientes. El control de identificación duplicada del repositorio ocurre después de comenzar esas escrituras. Tampoco se limpian allí todas las colecciones de historiales.

**Reproducción nueva con Isar real:** una base contiene un animal y un peso. Se importa JSON v3 con dos UUID distintos y el mismo arete. Se elimina el animal original, se guarda el primero y se rechaza el segundo. Queda un peso del animal eliminado; el siguiente respaldo normal falla por integridad referencial. Sí se genera una copia de emergencia, pero no hay recuperación automática.

Evidencia: `artifacts/auditoria-2026-10-18/backup_probe_test.dart`, prueba `legacy replaceAll`; resultado en `backup-probe.log`. La prueba pasa cuando reproduce el defecto; no significa que el importador sea correcto.

**Cierre:** convertir el formato antiguo al modelo canónico, validar identificación/unicidad/referencias antes de mutar y aplicar un reemplazo atómico. Probar que cualquier fallo conserva íntegramente la base anterior. Si se retira temporalmente la compatibilidad, rechazar el archivo antes de tocar datos y explicar la alternativa.

### D02 · P1 · Pesaje por lote duplica registros después de un fallo o al editar mientras guarda

`lib/features/directorio/lotes/application/lote_weighing_cubit.dart:192` guarda animal por animal sin transacción del lote ni identidad de reintento. Si A se guarda y B falla, el estado conserva los pesos de ambos; reintentar guarda A otra vez. `setWeight` (`:148`) y `setMeasuredAt` (`:139`) pueden sacar el estado de `saving`, permitiendo otro guardado concurrente. La pantalla mantiene campos y fecha editables. Además, su listener excluye los errores con estado `failure` y solo muestra el error en el cuerpo cuando no hay animales (`view/lote_weighing_page.dart:81`, `:104`).

**Reproducción:** repositorio controlado falla en B: primer intento `[A]`, reintento `[A,A,B]`. Con escritura suspendida, editar B y volver a guardar produce dos A y dos B. Dos pruebas en `ui_probe_test.dart` y `ui-probe.log`.

**Cierre:** lote atómico o UUID estables por operación/animal, reconocimiento de lo ya persistido y mensaje explícito de guardado parcial. Bloquear toda la captura y el cambio de fecha hasta terminar. Aceptar reintentos sin duplicar y mostrar el error sin perder captura.

### D03 · P1 · El registro rápido expone una lectura ficticia de báscula en offline

`lib/features/registro/view/registro_peso_page.dart:200` muestra «Tomar lectura de báscula» sin comprobar `hardwareIntegrationsEnabled`; `_readFromScale` (`:112`) tampoco lo comprueba. `lib/core/di/injection_native.dart:559`–`:564` registra incondicionalmente `SimulatedScaleAdapter`; ese adaptador devuelve 450 kg estables (`features/rfid/infrastructure/simulated_hardware.dart:159`, `:186`). El formulario acepta el valor como un pesaje ordinario.

**Reproducción en widget con offline activado y hardware deshabilitado:** tocar el botón llena `450.0` y muestra «Lectura de báscula cargada.». Evidencia: `scale_offline_probe_test.dart` y `scale-offline-probe.log`. Se utilizó el mismo adaptador que registra la inyección; no se conectó una báscula ni se guardó un registro real.

**Cierre:** ocultar y bloquear esta acción en público/demo según política, retirar simuladores de la inyección pública y etiquetar explícitamente cualquier simulación interna. Probar ambos accesos al pesaje: perfil y hub de Registros.

### D04 · P1 · Se guardan importes no finitos

`lib/core/utils/number_parsing.dart:9` devuelve `double.tryParse` sin `isFinite`. Las validaciones de ingreso (`features/finanzas/view/registro_ingreso_page.dart:132`) y gasto (`registro_gasto_general_page.dart:124`) solo rechazan nulo o `<=0`. Un teclado numérico no impide pegar texto. El repositorio (`infrastructure/isar_finanzas_repository.dart:47`, `:106`) tampoco valida ese contrato.

**Reproducción:** el parser acepta `NaN`, `Infinity` y `1e309`; la comparación de NaN con cero no lo rechaza. Isar real guarda NaN e infinito en ingresos. `exportJson` convierte ambos importes en `null`. Esto demuestra que la exportación ya no conserva el importe; no se ejecutó una restauración de ese archivo completo. Evidencia: tercer caso de `ui_probe_test.dart` y quinto de `backend_probe_test.dart`, con sus logs.

**Cierre:** rechazar valores no finitos en parser, entidad/servicio y repositorio; fijar límites y precisión monetaria; auditar los demás campos que usan ese parser. Verificar captura pegada y ciclo guardar/exportar/restaurar.

### D05 · P1 · Borrar el último movimiento no revierte ubicación ni fecha

`animal_projection_recalculator.dart:154` retorna si no quedan movimientos. No recupera la ubicación de registro ni limpia `lastMovementDate`.

**Reproducción Isar:** animal registrado en A, traslado a B, borrar ese traslado. Quedan cero movimientos, pero el animal sigue en B y conserva la fecha eliminada. Primer caso de `backend_probe_test.dart`.

**Cierre:** mantener un origen recuperable de la proyección y recalcular al borrar/corregir. Verificar también asignaciones manuales posteriores y conteos de ocupación, sin sustituir una ubicación legítima reciente.

### D06 · P1 · Borrar la enfermedad no limpia las alertas generadas

`animal_projection_recalculator.dart:191` activa `underObservation` y `requiresAttention` al encontrar enfermedad, pero no registra su origen ni revierte el efecto cuando desaparece la enfermedad.

**Reproducción Isar:** alta accidental de enfermedad, borrar su registro; historial sanitario vacío y ambos indicadores permanecen verdaderos. Segundo caso de `backend_probe_test.dart`.

**Cierre:** separar alertas manuales de alertas derivadas y recalcular estas últimas. No limpiar indiscriminadamente una observación manual o una alerta con otra causa válida.

### D07 · P2 · Restauración incompleta del perfil

`features/perfil/data/perfil_model.dart:76` exporta `region_state` y `production_setting`. `core/backup/isar_backup_store.dart:206`–`:213` reconstruye otros campos, omitiendo estos dos.

**Reproducción:** exportar Sonora/agostadero, cambiar destino a Jalisco/valle de riego, restaurar Reemplazar todo. Vuelve el nombre de la finca, pero región/sistema siguen en el destino. Primer caso de `backup_probe_test.dart`. Puede cambiar la adaptación regional de Biblioteca.

**Cierre:** contrato de ida y vuelta de todos los campos, valores predeterminados de versiones antiguas y decisión explícita para Merge. Considerar también el fallo de persistencia del perfil después de la transacción de colecciones: no se acreditó atomicidad entre Isar y preferencias.

## Backend y módulos que deben permanecer fuera del lanzamiento inicial

### S01 · P1 condicionado · RLS permite DELETE al rol cliente

La migración `supabase/migrations/20260911000100_farm_context_and_feature_records.sql:112` crea una política `FOR ALL`. `USING` autoriza al cliente sobre registros de sus animales; `WITH CHECK` lo excluye. `:140` concede DELETE al rol autenticado. Al borrar se evalúa `USING`, no `WITH CHECK`: el cliente puede borrar esos registros si esta migración está desplegada. Es un defecto confirmado por la definición SQL y la [semántica oficial de PostgreSQL](https://www.postgresql.org/docs/current/sql-createpolicy.html), **sin reproducción contra un servidor**.

Separar SELECT de INSERT/UPDATE/DELETE y probar cada combinación rol/finca/animal/operación. Además, veterinario y trabajador reciben el mismo poder sobre todos los `kind`; revisar que no puedan modificar contabilidad/nómina si sus contratos de rol no lo permiten. La prueba SQL existente cubre respaldos, no esta matriz.

### S02 · P1 condicionado · Nube y sincronización no están integradas de extremo a extremo

`core/persistence/json_feature_repository.dart:27` persiste con `store.put` sin encolar una operación. No se localizaron consumidores de `SyncEngine` en los flujos de app/features que cierren escritura→cola→servidor→otro dispositivo. Los animales nativos conservan un adaptador remoto sin operación real. Una cuenta telefónica no respalda ni sincroniza el rancho.

`core/sync/supabase_sync_gateway.dart:20` consulta revisión y escribe en solicitudes separadas: dos dispositivos pueden aprobar la misma revisión y sobrescribirse. `:44` pagina con `updated_at > cursor` y límite 1,000; filas con la misma fecha en el límite pueden saltarse. Son riesgos derivados del algoritmo, no una prueba realizada con dos servidores/teléfonos.

Requiere escritura atómica con revisión en servidor, deduplicación por operación, cursor compuesto estable, manejo de borrados/reintentos/conflictos e integración real del CRUD. Mantener la función deshabilitada hasta comprobar dos cuentas y dos dispositivos con desconexión.

### S03 · P1 condicionado · La identidad local del envelope no incluye finca

`core/persistence/isar_feature_record.dart:17` tiene UUID global único con `replace:true`, mientras las lecturas se filtran por finca. `isar_feature_record_store.dart:47` inserta sin comprobar propietario previo.

**Reproducción Isar:** insertar UUID X para finca A y luego el mismo X para B deja A sin registro y B con él. Cuarto caso de `backend_probe_test.dart`. Los UUID aleatorios reducen colisiones accidentales; el fallo importa al restaurar/importar/copiar registros o implementar multifinca. Los espacios locales separados reducen su alcance actual; no se demuestra fuga entre las bases de dos cuentas.

**Cierre:** identidad compuesta finca+UUID coherente en Isar/Drift/servidor o rechazo explícito de cambio de dueño. Probar importaciones con UUID repetidos y operaciones de otra finca.

### S04 · P1 condicionado · Un traslado de inventario descuenta sin acreditar destino

`features/ubicaciones/almacen/inventory_service.dart:14` calcula saldo solo con `locationId`; el traslado se registra una sola vez en origen (`:61`), y `destinationLocationId` no se usa para acreditar saldo.

**Reproducción Isar:** entrada 100 kg en A y traslado 40 kg a B produce A=60, B=0 y finca=60. Tercer caso de `backend_probe_test.dart`. No se localizó un flujo UI público que invoque hoy este traslado, por lo que no se presenta como un recorrido Android roto ya publicado.

**Cierre:** débito/crédito atómicos, conservación del total, unidades y valorización coherentes, más prevención atómica de sobreconsumo concurrente.

### S05 · Paridad web incompleta

`core/di/injection_web_repositories.dart:183` devuelve lotes vacíos; `createLote` lanza `UnsupportedError` y varias escrituras no hacen nada. `core/backup/web_backup_store.dart:40` restaura únicamente `featureRecords`, mientras Android guarda animales/historiales en colecciones separadas. No se debe anunciar intercambio completo Android/web sin transformación canónica o rechazo claro de respaldos incompatibles. No bloquea por sí solo un piloto Android local.

## Controles favorables y límites

Se observaron repositorios Isar, transacciones para numerosas operaciones individuales, validaciones por estado/fecha, UUID estables, historial editable, recalculado de proyecciones, respaldo moderno con verificación e inclusión de medios, copia previa a restauración, espacios invitado/demo y almacenamiento seguro de sesión. La suite nueva ejecutó pruebas reales de Isar, ciclo bovino y respaldos. Estos controles no eliminan los defectos anteriores.

Docker no estaba activo; no se ejecutaron las pruebas SQL ni se desplegaron migraciones. No se accedió a producción, SMS, datos reales del teléfono ni credenciales privadas. Las cinco pruebas de backend, dos de respaldo y las pruebas de UI se ejecutaron en recursos temporales/ficticios. El detalle de ejecución y las limitaciones de compilación están en el informe principal.
