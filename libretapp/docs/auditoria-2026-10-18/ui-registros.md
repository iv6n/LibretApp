# Auditoría de UI y flujos de registros — 18 de octubre de 2026

Se revisaron las rutas, pantallas y contratos de los 13 módulos de `lib/features`, componentes compartidos, formularios, BLoCs y repositorios; se ejecutó la suite completa existente. Una revisión de código de todos los módulos **no equivale a probar cada combinación en un teléfono**. La matriz principal identifica esa diferencia.

## Hallazgos y criterios de aceptación

| ID | Prioridad / evidencia | Problema y reproducción | Cierre esperado |
| --- | --- | --- | --- |
| D02 | P1; dos reproducciones nuevas | Pesaje de lote A/B: falla B, reintentar duplica A; editar durante guardar permite otra escritura. Error parcial queda sin mensaje con animales presentes | Operación atómica/idempotente, campos/fecha bloqueados y error visible; reintentar conserva captura sin duplicar |
| D03 | P1; widget offline reproducido | Registro rápido de peso ofrece báscula simulada, carga 450 kg y dice que la lectura fue recibida | Aplicar gate en UI y acción, y retirar adaptador simulado de público; comprobar ambos accesos al peso |
| D04 | P1; parser e Isar reproducidos | Pegar NaN/Infinity/1e309 en importes atraviesa el parser y los controles `<=0`; Isar admite valores no finitos | Validación finita y monetaria en todas las capas, incluyendo pegado/importación |
| U01 | P1; capturas nuevas y cálculo | Perfil oscuro: «Resumen» seleccionado tiene contraste bajo; algunos iconos y metadatos también resultan oscuros | Paleta de contenido interactivo para oscuro; medir combinaciones reales, texto normal >=4.5:1 como referencia de accesibilidad |
| U02 | P2; código y preview offline nuevos | Crear/vincular cuenta se ofrece en una variante cuyo servicio de teléfono está deshabilitado | Acciones y textos dependen de disponibilidad real; instalación limpia termina en una tarea realizable |
| U03 | P1 en borrado; P2 en edición; código | Papelera en ingresos/gastos ejecuta borrado inmediato; no hay flujo para editar desde la lista | Confirmación o deshacer fiable y edición con identidad estable; errores conservan captura |
| D08 | P1; código, error de lectura no inyectado en widget | Edición de peso/producción/movimiento/comercial/costo espera repositorio sin catch/finally y puede quedar cargando | Error visible y reintento; no pantalla vacía/ocupada indefinidamente; captura preservada |
| U04 | P2; código | La copia de emergencia se escribe en almacenamiento privado, pero la interfaz no permite encontrarla/recuperarla | Listar/exportar/restaurar copias previas de forma comprensible y confirmar qué se reemplaza |
| F01 | P2; funcionalidad declarada pendiente | Reportes sanitario y reproductivo solo muestran «Próximamente» | Implementarlos si forman parte de la promesa del lanzamiento; de lo contrario ajustar ficha y navegación |

Referencias precisas:

- D02: `features/directorio/lotes/application/lote_weighing_cubit.dart:139`, `:148`, `:192`; `view/lote_weighing_page.dart:81`, `:104`, `:167`.
- D03: `features/registro/view/registro_peso_page.dart:112`, `:200`; `core/di/injection_native.dart:559`–`:564`.
- D04: `core/utils/number_parsing.dart:9`; `features/finanzas/view/registro_ingreso_page.dart:132`; `registro_gasto_general_page.dart:124`.
- U01: `theme/app_theme.dart:7`, `:50`, `:476`; `features/directorio/animales/view/animal_detail_page.dart:430`. Selección usa `colorScheme.primary` verde bosque sobre superficie oscura.
- U02: `features/onboarding/onboarding_page.dart:194`; `features/perfil/view/account_settings_card.dart:81`; `features/onboarding/phone_auth_sheet.dart:199`. El router entrega la acción sin comprobar disponibilidad del proveedor.
- U03: `features/finanzas/widgets/record_tile.dart:77`; `view/finanzas_page.dart:126`; contrato en `domain/repositories/finanzas_repository.dart:11`.
- D08: `features/directorio/animales/view/animal_weight_form_page.dart:57`, `animal_production_form_page.dart:59`, `animal_movement_form_page.dart:72`, `animal_commercial_form_page.dart:58`, `animal_cost_form_page.dart:55`. Salud, reproducción y destete tienen un tratamiento de carga distinto y no se incluyen en este defecto.
- U04: `core/services/backup_service_native.dart:603`; `features/perfil/view/perfil_settings_sheet.dart:426`.
- F01: `features/reportes/view/tabs/reportes_summary_tab.dart:285`–`:304`.

El contrato de Finanzas permite guardar mediante `addIncome`/`addExpense`, y su implementación puede reutilizar un ID existente; lo que falta es la acción de edición accesible al usuario. No se afirma que el modelo de datos sea incapaz de actualizarse.

## Verificación visual nueva

Se generaron y se inspeccionaron:

- `artifacts/auditoria-2026-10-18/visual/profile-cattle-light.png`.
- `artifacts/auditoria-2026-10-18/visual/profile-cattle-dark.png`.
- `artifacts/auditoria-2026-10-18/visual/onboarding/bienvenida.png`.
- `artifacts/auditoria-2026-10-18/visual/onboarding/opciones.png`.

Son renders Flutter de datos ficticios, no capturas de una instalación del AAB final. Las dos variantes del perfil a 360 dp pasan las aserciones de layout; el texto seleccionado en oscuro sigue siendo difícil de leer. El contraste de los colores declarados `#2F5D50` sobre `#0F1B1F` es aproximadamente **2.34:1**. Como referencia, [WCAG 2.2 describe 4.5:1 para texto normal y 3:1 para texto grande](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html). No se certificó conformidad WCAG de toda la app.

La captura de opciones muestra la cuenta telefónica como botón destacado incluso al compilar la preview con el flag offline. El callback de esa preview es ficticio; la indisponibilidad de la acción real se verifica aparte en el servicio y en el router.

La suite completa también ejecuta las 48 combinaciones del perfil (especies, temas, tamaños), formularios de registros con texto ampliado y teclado, errores de guardado, cultivo/ubicación, reintentos de streams, agenda, onboarding y cierre de árboles. Eso aporta evidencia automatizada de escenarios concretos, sin sustituir TalkBack, teclado real, permisos o rendimiento del dispositivo.

## Matriz funcional revisada

| Área | Flujos / registros examinados | Evidencia actual y pendientes |
| --- | --- | --- |
| Inicio | Resumen, accesos rápidos, configuración de widgets, indicadores | Servicios y tests presentes; revisar contraste oscuro y datos luego de correcciones; widget de almacén permanece futuro |
| Directorio/animales | Alta rápida/completa, edición, identificación/duplicados, búsqueda, vistas, perfil, asignación, genealogía, historial | Cobertura extensa; una prueba de tarjeta y una de persistencia del modo de directorio fallan por montaje |
| Peso | Individual, edición/borrado, por lote, GDP | Reproducciones D02/D03/D05; controlar datos no finitos en entradas que compartan parser |
| Salud/cuidados | Vacuna, desparasitación, enfermedad, tratamiento, programación | Validaciones y ciclos presentes; alertas no se revierten al borrar enfermedad (D06) |
| Reproducción/destete | Servicio, toro, diagnóstico, parto con/sin servicio, aborto, nacimiento muerto, crías, vínculo, destete | Tests del ciclo bovino y formularios; completar ciclo desde cada entrada en Android final |
| Producción | Peso, condición corporal y registros productivos por política | Persistencia presente; D08 al cargar edición; no afirmar profundidad equivalente en todas las especies |
| Comercial/costos/movimientos | Compra/venta/muerte, gasto animal, origen/destino, edición/borrado | Proyecciones y políticas presentes; ubicación incorrecta tras borrar último movimiento; D08 |
| Lotes | Crear/editar/cerrar, asignar animales, detalle, rendimiento, pesaje | D02; alimentación tiene servicios y consulta, no un flujo completo acreditado de captura de raciones |
| Ubicaciones | Crear/editar, ocupación, visitas, agua, sal, sombra, pastura, actividad | Tests de BLoC/cubit, guardado y errores; completar permisos rechazados y recorridos en físico |
| Cultivos | Alta, vínculo, detalle, cosecha, riego, salud y tareas | Tests de guardado/reintento, layout 320 dp y texto 2x; aceptación final con teclado Android pendiente |
| Inventario | Artículos y registros; kardex en módulo compartido | Transferencia del servicio pierde cantidad de destino (S04), no se acreditó su exposición pública actual |
| Agenda/personal | Crear/editar/completar tareas, acciones por animal/lote, equipos | Persistencia y tests presentes; no se localizó notificación local del sistema con app cerrada |
| Ordeña | Sesión, turno, animal, litros, indicadores/exportación | Modelo, repositorio y pruebas presentes; validar turno/día y filtros con datos reales de productor |
| Finanzas | Ingreso, gasto, eliminación, resumen, rentabilidad | D04 y U03; agregar corrección accesible y borrado reversible |
| Reportes/exportación | Resumen, finanzas, Excel, importación, respaldos y medios | F01; D01/D07 en recuperación; exportación exitosa no prueba restauración completa |
| Biblioteca | Libros/capítulos, adaptación región/sistema, navegación | Tests e integración de assets presentes; perfil restaurado incompleto puede alterar selección regional |
| Perfil/ajustes | Finca, tema, cuenta, espacios, demo, privacidad, backup | U02/U04, privacidad incompleta; separar cuenta de sincronización real |
| RFID/báscula/GPS/proveedores | Adaptadores e integraciones internas | Mantener deshabilitados en público; fuga de báscula en hub corregible por D03 |

## Pruebas fallidas y límites de aceptación

La ejecución nueva produjo **1,142 éxitos y 2 errores**, sin pruebas omitidas, en aproximadamente cinco minutos. El fallo de `animal_card_compact_footer_test.dart` se debe a que no monta los delegados de localización que usa `AnimalCard`; la app principal sí los monta. El de `directorio_bloc_search_test.dart:77` reutiliza BLoCs hijos después de cerrar el padre, que también los cierra (`directorio_bloc.dart:495`), y agota la espera. Corregir estos montajes es requisito para recuperar una suite verde; los dos fallos por sí solos no demuestran dos defectos en la app instalada.

No se ejecutó un recorrido nuevo en el teléfono conectado: estaba en otra aplicación. Solo se consultó versión instalada/API/tamaño de página. No se abrieron sus datos ni se modificó su instalación. Continúan pendientes: TalkBack, controles táctiles, permisos rechazados, Android mínimo/actual, cierre forzado durante escritura, poco espacio, restauración en instalación limpia y actualización con el paquete final. No se acredita rendimiento de dibujo con 1,000 animales por una prueba de consultas de repositorio.
