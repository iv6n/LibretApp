# Primera etapa: importación del hato y registros por lotes

Implementación del 24 de octubre de 2026. Se conservan las colecciones existentes, el esquema 11 de respaldo y los cambios previos del proyecto.

## Importar el hato

Accesos: **Registros → Importar hato** y **Perfil → Ajustes → Importar hato (Excel o CSV)**.

1. Seleccionar `.xlsx`, CSV UTF-8 o TSV. Se utiliza la hoja `Animales` si existe o la primera hoja con datos.
2. Revisar la asignación automática de columnas y corregirla si es necesario. Se reconocen los encabezados de la exportación actual, incluidos UUID y precisión del nacimiento; el orden puede variar.
3. Generar una vista previa. Leer y revisar no escribe animales.
4. Elegir por fila **Crear**, **Actualizar** u **Omitir**. Las coincidencias existentes se omiten de manera predeterminada; las filas con errores no se pueden seleccionar.
5. Revisar los totales y confirmar. La selección se guarda en una sola transacción local.

Ejemplo de CSV:

```csv
Arete,Nombre,Especie,Sexo,Raza,Fecha Nac.,Peso
000012345678,Luna,cattle,female,Criollo,01/04/2022,320.5
000012345679,Lucero,cattle,male,Criollo,15/06/2023,410
```

También se admiten nombres de especie y sexo en español, delimitador de punto y coma, celdas entre comillas y comas decimales. Los identificadores se conservan como texto. Si Excel los almacenó como números, la vista previa avisa que se deben revisar los ceros iniciales; no se inventan ceros perdidos en el archivo de origen.

La detección contempla repeticiones dentro del archivo, identificadores visuales/RFID y animales inactivos. Las repeticiones del archivo se muestran en todas las filas implicadas. Las coincidencias ambiguas se bloquean. Para cambiar el arete, la especie o el sexo de un animal existente se utiliza su perfil, con las validaciones de su historia.

Se comprueba también el arete principal que produciría cada fila, incluyendo los registros que solo traen RFID. Se bloquean las colisiones y las combinaciones de columnas que dejarían una identificación asignada sin guardar. Una cadena usada como RFID y como arete visual de otro animal conserva su tipo y no provoca una unión automática.

Los campos vacíos conservan los valores existentes. La importación básica no reemplaza genealogías, fotografías ni registros operativos. Un animal sin fecha de nacimiento conserva precisión desconocida; una fecha inferida de la edad queda estimada. Los valores predeterminados de especie y sexo se avisan en la revisión. Los errores de fecha, enumeración y peso permanecen visibles.

Antes de escribir se vuelve a comprobar la identidad y la versión revisada de los animales. Si el hato o la finca cambiaron, se pide generar una vista previa nueva. Un fallo revierte la importación completa y permite reintentar. Reabrir el mismo archivo muestra las coincidencias y las omite de forma predeterminada.

Esta operación importa datos básicos. Para recuperar un hato con toda su historia y sus medios se utiliza el respaldo `.libretbackup`.

## Sesiones por lotes sin conexión

Accesos: **Registros → Registro por lotes** o **detalle del lote → Registro por lotes sin conexión**. Disponibles en la aplicación instalada y en la versión web. En web se utiliza SQLite/WASM con Drift y almacenamiento persistente del navegador, separado por espacio de trabajo y finca.

La sesión guarda un listado fijo de los animales activos que pertenecían al lote al iniciarla. Añadir o retirar integrantes después no cambia ese listado histórico.

- **Pesaje:** peso por animal, fecha, responsable y notas. Un peso vacío queda sin registro y un peso inválido impide confirmar. Los pesajes conservan el lote de origen y el método de báscula.
- **Sanidad:** tipo, producto, dosis registrada, responsable, lote del medicamento, retiro y próxima aplicación. Se utilizan las validaciones sanitarias existentes. No se ofrece muerte colectiva desde este formulario.
- **Movimiento:** destino, motivo, fecha, responsable y notas, conservando el origen individual. Si el origen cambió durante la sesión, debe revisarse el animal. La posición del lote se actualiza cuando se trasladaron todos sus integrantes actuales.

La captura conserva la hora del evento para ordenar los movimientos del mismo día. Un registro retroactivo se añade a la historia; las ubicaciones actuales del lote y de los animales se mantienen según el movimiento vigente más reciente.

Cada cambio se escribe como borrador local en el orden de captura. Se conservan incluso los valores todavía inválidos para poder corregirlos al reanudar. La pantalla distingue guardado pendiente, borrador guardado y fallo de almacenamiento; un fallo permite volver a guardar. Se puede regresar a la lista de sesiones, reabrir un borrador o descartarlo explícitamente.

Al confirmar se validan de nuevo los animales y los datos. Los registros individuales y el cierre de la sesión comparten una transacción local: un fallo en un animal o en el cierre revierte todo. Cada registro tiene una identidad estable derivada de la sesión y del animal. Confirmar otra vez una sesión completada devuelve su resultado sin volver a aplicar los eventos.

Las sesiones terminadas conservan su resumen y sus integrantes. Las correcciones posteriores de registros individuales siguen realizándose desde el historial del animal. El resumen de la sesión acredita su confirmación original; no sustituye el historial corregido.

Los borradores y cierres se almacenan en `featureRecords` con tipo `record.batch_session`. Ya forman parte de los respaldos existentes y sobreviven al cierre de la base y a una restauración completa, sin generar un esquema nuevo. No requieren autenticación remota, señal, lectores ni servicios externos. Los permisos locales de la finca se comprueban al abrir, editar y confirmar; sanidad requiere permiso para gestionar salud.

### Funcionamiento web

Los lotes, las ubicaciones y los registros de peso, sanidad y movimientos utilizan repositorios persistentes sobre la misma base que las sesiones. La confirmación incluye las proyecciones del animal, la posición del lote y el comprobante en una sola transacción. Los streams del directorio publican los datos confirmados y no muestran escrituras que después se revierten.

La versión del borrador se comprueba dentro de la transacción. Una pantalla atrasada debe volver a abrir la sesión antes de editar o confirmar. Dos confirmaciones de la misma sesión utilizan los mismos UUID de registro; una vez terminado el guardado, los reintentos devuelven el comprobante original, incluso tras cerrar y volver a abrir la base.

El guardado espera también a que IndexedDB persista el último COMMIT. La prueba real en Chrome detectó que el adaptador WASM podía reconocer la última escritura antes de vaciarla al almacenamiento; se añadió una barrera posterior a la transacción para esperar esa persistencia antes de mostrar éxito. Las transacciones anidadas conservan el mismo ámbito y la barrera se aplica al cierre exterior. El worker se recompiló con las dependencias actuales; su fuente reproducible está en `tool/drift_worker.dart`.

Las escrituras que conservan una referencia al almacén original también se incorporan al ámbito de la transacción exterior. Así no abren savepoints que liberen antes de tiempo el bloqueo de OPFS frente a las consultas del directorio. La importación y la confirmación por lotes mantienen un único cierre atómico y revierten todas sus escrituras si falla la operación.

Para usar la web sin red, abrirla inicialmente con conexión y dejar que termine la carga y la instalación de su caché local. El service worker conserva el programa, el motor gráfico, SQLite/WASM, su worker y los recursos esenciales. El motor gráfico y las fuentes Roboto se sirven desde el mismo sitio. La recuperación sin red de una ruta usa el documento inicial; un recurso binario ausente no se sustituye por HTML.

El navegador debe permitir almacenamiento persistente y coordinación entre pestañas mediante OPFS o SharedWorker. El arranque rechaza los modos temporal en memoria y el fallback de IndexedDB sin coordinación, que no permiten ofrecer las mismas garantías de guardado y concurrencia.

Los datos pertenecen a ese navegador y a ese sitio. Borrar sus datos elimina también los borradores locales; el respaldo sigue siendo la vía para conservar una copia fuera del navegador. No hay sincronización automática con otro equipo.

## Validación

Las pruebas específicas están en:

- `test/core/services/herd_import_service_test.dart`: lectura sin escrituras, exportación Excel actual, CSV, ceros iniciales, duplicados, decisiones explícitas, datos existentes, cambio de finca, cambios concurrentes y rollback.
- `test/core/persistence/drift_feature_record_store_test.dart`: las escrituras del almacén original comparten la transacción exterior sin abrir bloqueos anidados; los errores revierten el lote completo y permiten reintentar.
- `test/features/directorio/lotes/lote_form_page_test.dart`: creación y edición desde una ruta sin el bloc del directorio, con recuperación y reintento si falla el almacenamiento. El formulario espera al repositorio antes de cerrarse.
- `test/features/registro/batch_record_service_test.dart`: Isar real, cierre y reapertura, restauración de borradores, pesos, tratamientos, movimientos, participantes originales y reintentos, incluidos fallos al guardar el cierre.
- `test/features/registro/web_batch_record_test.dart`: los mismos repositorios de producción web sobre Drift; persistencia al reabrir, confirmación concurrente y repetida, fallos de cierre o tratamiento, rollback de proyecciones, origen desactualizado, fechas retroactivas, versiones, permisos, aislamiento por finca y respaldo. Se puede ejecutar en VM con SQLite o en Chrome con SQLite/WASM e IndexedDB.
- `test/features/registro/phase_one_pages_test.dart`: revisión y cancelación, elección de actualizaciones, reintentos, reanudación, fallos de autoguardado y pantallas de 320 dp con texto doble y teclado.
- `test/web/service_worker_test.cjs`: seis pruebas de precarga, rutas bajo un subdirectorio, binarios sin red, errores HTTP y limpieza limitada a las cachés de LibretApp.
- `test/web/offline_batch_smoke_app.dart` y `tool/verify_web_batches.cjs`: aceptación real en Chrome con la fábrica y el worker de producción. Guarda un borrador, corta las respuestas del servidor y la red del navegador, recarga toda la página y reanuda la captura; verifica confirmación concurrente, reapertura de base, retiros sanitarios y rollback del movimiento completo cuando falla su comprobante.

Para repetir la aceptación web desde la raíz del proyecto, con Flutter, Node y Chrome instalados:

```powershell
flutter build web --release --no-wasm-dry-run --target test/web/offline_batch_smoke_app.dart --output build/web-batch-smoke
node tool/verify_web_batches.cjs
node --test test/web/service_worker_test.cjs
```

`CHROME_EXECUTABLE` permite indicar otro ejecutable compatible. El comprobador abre un perfil temporal aislado en `artifacts/`, lo cierra al terminar y guarda el resultado en `artifacts/web-batch-browser-smoke-result.json`. No utiliza el perfil habitual del usuario.

Los resultados de esta ejecución se conservan en `artifacts/etapa1-*.txt`. La comprobación en un teléfono físico forma parte de la aceptación del piloto; las pruebas automatizadas no se presentan como una jornada de campo real.

Resultados locales:

- Suite general: **1,235 pruebas aprobadas y una omitida**, con concurrencia 2.
- Pruebas específicas finales de esta etapa: **31 aprobadas**.
- Análisis final: **cero errores y cero advertencias**; 318 avisos informativos en el árbol actual.
- Compilación web de producción: **correcta**, sin publicar ni desplegar el resultado.

Se actualizó la prueba de estilo del menú por sus dos accesos nuevos. La prueba de eventos del repositorio ahora se suscribe antes de guardar, actualizar o eliminar, para evitar perder una emisión de su stream de difusión.

La ampliación web se verificó además con **1,254 pruebas aprobadas y una omitida** en la suite general; después de la corrección de persistencia se aprobaron **54 pruebas específicas** de registros, almacenamiento compartido, importación y pantallas. Los seis casos del service worker también se aprobaron. La aceptación en Chrome confirmó recarga sin red, borrador reanudado, dos pesajes, dos registros sanitarios y dos movimientos, sin duplicados y con rollback del comprobante fallido. Evidencia local en `artifacts/web-batch-*`.

El análisis final de la ampliación dio **cero errores y cero advertencias** (336 avisos informativos en el árbol actual). La compilación web de producción terminó correctamente; se comprobó también que todos sus recursos de precarga existen y que incluye las fuentes locales, el motor gráfico local y el worker recompilado. El resultado permanece local, sin despliegue.

La aceptación del 25/10/2026 en el navegador integrado, usando OPFS, importó un CSV de 16 filas: diez animales válidos y seis filas omitidas (cuatro afectadas por duplicados, una sin identificación y una con peso negativo). Una segunda vista previa mostró cero animales nuevos y diez coincidencias. Se guardó un borrador con dos pesos, se detuvo el servidor local y se comprobó el rechazo de sus conexiones HTTP. Tras recargar se reanudaron ambos pesos, se añadió el tercero y se confirmó la sesión. Otra recarga y la consulta de los tres historiales conservaron un único pesaje por animal. Con el servidor restablecido, el mismo comprobante siguió mostrando tres registros. Las dos correcciones de esta aceptación quedaron cubiertas por **38 pruebas específicas aprobadas**, una compilación web de producción correcta y análisis estático sin incidencias en los cuatro archivos revisados.

Una segunda aceptación del 25/10/2026 comprobó sanidad y movimientos con Luna, Canela y Lucero. Los dos borradores recuperaron sus campos después de recargar con el servidor local detenido; las notas modificadas sin servidor también sobrevivieron a otra recarga. Se confirmaron tres chequeos ficticios y tres reubicaciones a **Potrero DEMO destino**. Tras recargar de nuevo y reabrir los comprobantes, cada historial conservó exactamente un sanitario y un movimiento. El lote completo y los tres animales quedaron en el destino seleccionado. El servidor se restauró y las sesiones siguieron completadas.

Durante esta revisión se corrigió un error del listado: al activar la pestaña Lotes, el contenedor del botón flotante desmontaba y recreaba la suscripción de ubicaciones. La suscripción permanece ahora por encima de ese contenedor, conservando sus datos y actualizaciones. La regresión reprodujo el fallo original; las **cinco pruebas del listado** aprobaron, el análisis de los dos archivos quedó sin incidencias y la compilación web terminó correctamente. La comprobación posterior en el navegador permitió alternar entre Animales y Lotes sin error. Las evidencias y los detalles visuales pendientes están en `outputs/01a17006-2857-7d73-98ed-bb11bbc256b6/sanidad-movimientos/resultado-sanidad-movimientos.md`.

Se corrigió después el detalle visual del historial de movimientos: los nombres de origen y destino se resuelven por UUID desde el repositorio local, también para potreros archivados, conservando las referencias originales de los eventos. Los nombres escritos en registros antiguos siguen visibles y una salida sin destino se presenta como **Sin ubicación**. Las **tres pruebas de regresión** aprobaron, el análisis de los cinco archivos revisados quedó sin incidencias y la compilación web terminó correctamente. Con el servidor local detenido se recargó toda la aplicación y se abrieron los historiales de Luna, Canela y Lucero: cada uno mostró **Potrero DEMO destino**, sin el UUID y con un único movimiento. El servidor se restauró y el historial quedó abierto. Evidencias en `outputs/01a17006-2857-7d73-98ed-bb11bbc256b6/historial-movimientos-nombres/resultado-nombres-historial.md`.

Se comprobó además la persistencia al cerrar la única pestaña del navegador integrado y abrir otra con el mismo perfil, dos veces y con el servidor local detenido. Los **tres borradores** de pesaje, sanidad y movimiento reaparecieron con sus campos; se confirmaron sin servidor y, tras el segundo cierre, quedaron **seis sesiones completadas y cero borradores**. Los historiales de Luna, Canela y Lucero conservaron el registro anterior y exactamente **uno nuevo de cada tipo**: nueve registros nuevos, sin duplicados. Los comprobantes completados no ofrecieron una segunda confirmación. El servidor se restauró. Alcance y evidencia en `outputs/01a17006-2857-7d73-98ed-bb11bbc256b6/reapertura-navegador-offline/resultado-reapertura-offline.md`.
