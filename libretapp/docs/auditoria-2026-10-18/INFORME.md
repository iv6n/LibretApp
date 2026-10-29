# Preparación para Google Play — auditoría del 18 de octubre de 2026

**Seguimiento:** este documento conserva el diagnóstico original. Las
correcciones y el estado vigente se registran en [la implementación del 19 de
octubre](../auditoria-2026-10-19/IMPLEMENTACION.md) y su [registro de cierres](../auditoria-2026-10-19/cierres.csv).

**No recomiendo publicar todavía en producción.** LibretApp tiene una base funcional amplia y muchas pruebas, pero esta revisión reprodujo pérdida de datos al restaurar un formato antiguo, duplicación de pesajes y una lectura ficticia de báscula expuesta en el piloto offline. Primero hay que cerrar esos defectos y validar un candidato Android nuevo.

No hace falta implementar todos los módulos futuros para lanzar. Para una primera versión, el alcance más cercano es **Android offline, gratuito, con registros locales, invitado y demo**. La versión con cuentas/SMS y la sincronización remota necesitan una aceptación adicional; una cuenta no equivale a un respaldo del rancho.

## Qué se revisó y qué se ejecutó

Se revisaron navegación, UI compartida, formularios, ciclo de guardado y errores, los 13 módulos de `lib/features`, repositorios Isar, respaldos y medios, perfil, cuentas, espacios locales, sincronización, RLS Supabase, configuración Android, firma, permisos, CI y documentación de publicación. Base Git `f5a12b5`, rama `feature/ui-polish-design-system`, incluyendo los cambios locales existentes; versión `0.1.2+5`, esquema de respaldo 10. Se conservaron esos cambios; esta entrega es de análisis, sin correcciones del código de producto ni publicación.

| Verificación nueva | Resultado |
| --- | --- |
| `flutter analyze --no-pub --no-fatal-infos` | Aprobada: 0 errores, 0 advertencias, 194 avisos informativos; 352.7 s |
| Suite completa `flutter test --no-pub --reporter json` | **1,142 aprobadas / 2 fallidas**, 0 omitidas, 149 archivos con resultados; 298.4 s |
| Reproducciones de defectos | **11/11** confirman los comportamientos descritos; son diagnósticos, no aceptación del producto |
| Restricciones offline con configuración ficticia de proveedores | 1/1 aprobada; esa prueba no detectaba el botón de báscula filtrado en la UI |
| Capturas nuevas de widgets | Perfil bovino claro/oscuro y onboarding; renders inspeccionados con datos ficticios |
| Compilación nueva AAB offline | **No completada**: fallo de comunicación interna JVM/Gradle, detallado abajo |
| AAB ya existente | Firma verificada por `jarsigner`; 18 bibliotecas inspeccionadas, todos los ELF de 64 bits pasan el chequeo de alineación del script. No certifica el árbol actual |
| Backend remoto/SMS | Sin despliegue ni pruebas reales; Docker no estaba activo; no se accedió a producción |

Entorno: Windows, Flutter 3.47.5, Dart 3.13.4. La huella de 891 archivos de código/configuración/pruebas revisados está registrada en `artifacts/auditoria-2026-10-18/fuentes-sha256.json`; no incluye credenciales privadas.

Las pruebas fallidas son `animal_card_compact_footer_test.dart` (faltan delegados de localización en el montaje) y `directorio_bloc_search_test.dart` (reutiliza BLoCs hijos cerrados y agota la espera). La app principal sí registra localización. Debe recuperarse una suite verde; estos fallos no demuestran por sí solos dos errores del usuario en la app instalada.

## Pendientes que deben cerrarse antes de producción

P0 significa pérdida de datos reproducida; P1, defecto funcional/integridad o condición de salida que impide aprobar el candidato; P2, mejora o deuda de alcance. Una prueba manual pendiente y un defecto reproducido se registran por separado.

| Orden | Hallazgo | Alcance e impacto | Criterio de cierre |
| --- | --- | --- | --- |
| 1 | **D01 · P0 · Restauración antigua destructiva** | Un JSON v3 con arete duplicado borra el animal previo, importa parcialmente y deja historial huérfano; el siguiente backup falla | Validar antes de escribir, convertir al contrato moderno y restaurar atómicamente; rollback demostrado |
| 2 | **D02 · P1 · Pesaje de lote no idempotente** | Falla B después de guardar A; reintentar duplica A. Editar durante guardar permite dos operaciones. El fallo parcial puede quedar silencioso | Transacción/UUID estable, bloqueo de campos y fecha, reintentos sin duplicado y mensaje de error visible |
| 3 | **D03 · P1 · Báscula simulada pública** | El hub de Registros en offline carga **450 kg** del simulador y presenta éxito | Gate en UI/acción y adaptador público seguro; simulación solo interna y explícita |
| 4 | **D04 · P1 · Importes inválidos persistidos** | NaN/Infinity atraviesan parser/validación y se guardan en Isar; exportados aparecen como null | Rechazar no finitos y validar dinero en repositorio, formulario e importación |
| 5 | **D05/D06 · P1 · Correcciones no revierten todo** | Borrar último movimiento conserva ubicación/fecha; borrar enfermedad conserva alertas generadas | Reconstruir proyecciones y distinguir valores manuales de los derivados |
| 6 | **U03/D08 · P1 · Corrección y recuperación de errores** | Finanzas elimina con un toque; no ofrece editar. Cinco formularios de edición carecen de recuperación ante error de lectura | Confirmar/deshacer borrado, edición accesible, error/reintento y captura retenida |
| 7 | **U01 · P1 · Contraste oscuro** | Selección «Resumen» del perfil usa verde oscuro sobre superficie oscura, ~2.34:1 en colores declarados | Paleta accesible para contenido activo; revisar selección, iconos, metadatos y TalkBack |
| 8 | **D07/U04/U02 · P2 · Flujos por terminar** | Restore omite región/sistema productivo; copia previa no recuperable desde UI; cuenta ofrecida aunque offline no la permite | Ida/vuelta de perfil completo, acceso a copias previas y onboarding coherente |
| 9 | **PUB-01 · P1 · Privacidad/soporte definitivos** | Política conserva responsable/correo por completar; el build puede omitir contacto y URL | Titular y correo reales, política HTTPS publicada, parámetros y declaraciones Console coherentes |
| 10 | **P02/P03/P04 · Salida sin aprobar** | Suite roja, AAB nuevo sin verificar, aceptación física incompleta | Suite verde y paquete final con hash, instalación/actualización/recuperación verificadas; recorridos físicos completados |

Cada defecto incluye archivo/línea, escenario y propuesta en [backend](backend.md) y [UI/registros](ui-registros.md). El [registro CSV de hallazgos](hallazgos.csv) permite dar seguimiento a su cierre sin confundirlos con nuevas funciones.

## Funciones actuales y lo que falta implementar

| Área | Lo que ya existe | Pendiente antes de afirmar que está completa |
| --- | --- | --- |
| Animales e historial | Altas rápida/completa, identificación, búsqueda, perfiles, lotes/ubicación, registros, genealogía | D03/D05/D06/D08; pruebas fallidas y aceptación de los accesos reales |
| Reproducción bovina | Servicio, diagnóstico, parto con/sin servicio, aborto, nacimiento muerto, crías, destete y corrección de ciclo | Recorrido Android completo desde perfil y hub hasta respaldo/restauración; no extrapolar esa profundidad a todas las especies |
| Lotes y peso | Asignación, cierre, rendimiento/GDP y captura masiva | D02; alimentación tiene servicios/consulta, falta acreditar captura completa de raciones y consumo |
| Ubicaciones/cultivos | Ocupación, visitas, agua/sal/sombra/pastura, cultivos, cosecha, riego, salud y tareas | Aceptación física de formularios; el servicio de transferencias del nuevo kardex tiene S04 |
| Agenda/personal | Tareas, relaciones por animal/lote, recordatorios internos y equipos | No se encontró integración de notificaciones locales con la app cerrada; implementarla si se anuncian avisos del sistema |
| Ordeña y finanzas | Sesiones/turnos/registros, resumen, ingresos/gastos y exportación | D04/U03 y validación con datos representativos; cobros/fiscal son adaptadores internos, no producto listo |
| Reportes | Indicadores, resumen financiero, Excel y respaldos | Reportes sanitario y reproductivo detallados siguen «Próximamente»; implementación o ajuste explícito de alcance/ficha |
| Biblioteca/perfil | Contenido y adaptación regional, perfil, tema, ajustes y espacios | Restauración de región/sistema D07 y pruebas de lectura/accesibilidad |
| Recuperación | Formato moderno con medios, verificación y copia previa; compatibilidad antigua | D01/D07/U04; ciclo completo de recuperación en candidato final |

La [matriz de UI/registros](ui-registros.md) recorre cada familia de registros. [Resultados por módulo](resultados-por-modulo.csv) cuenta casos automatizados ejecutados; **no es porcentaje de cobertura de líneas ni prueba exhaustiva de todas las pantallas**.

## Si se quieren cuentas y nube en el primer release

Estos pendientes son adicionales al piloto offline y deben mantenerse fuera de su promesa comercial hasta cerrarse:

- **Cuenta telefónica:** falta operación SMS real validada y eliminación de cuenta/datos desde la app y mediante recurso web. El cierre de sesión actual no elimina el usuario remoto. Google exige ambos caminos cuando se ofrece creación de cuenta: [requisito de eliminación](https://support.google.com/googleplay/android-developer/answer/13327111).
- **Sincronización:** no está cerrado el recorrido CRUD→cola→servidor→otro teléfono. El gateway tiene riesgos de sobrescritura por revisión no atómica y de omisión de filas por cursor de fecha con límite. Integrar y probar desconexión, reintentos y conflictos reales.
- **RLS y roles:** una política `FOR ALL` permite al cliente borrar registros de sus animales; trabajadores/veterinarios comparten poderes generales. Separar lectura/escritura y verificar matriz de permisos antes del despliegue. No se probó un servidor remoto.
- **Multifinca:** un UUID global con reemplazo puede sustituir el registro de otra finca dentro del mismo store. Se reprodujo en Isar; las bases separadas por espacio reducen la exposición actual.
- **Kardex nuevo:** traslado 40 de A a B descuenta 40 del total y no acredita B; se reprodujo en el servicio, sin afirmar que ya exista el recorrido UI público.
- **Web:** lotes tiene operaciones vacías/no implementadas y el contrato de respaldo no convierte todas las colecciones Android. No anunciar paridad completa.

Los detalles, alcances y medidas de cierre están en los documentos anexos. El piloto local puede funcionar sin backend remoto si se corrigen sus defectos propios.

## Paquete Android y Google Play

SDK objetivo 36, `app.libret`, firma release privada y overlay de permisos offline ya están configurados. API 36 satisface el requisito actual para nuevas apps de teléfono: [documentación de Google Play](https://support.google.com/googleplay/android-developer/answer/11926878). `standard` pública conserva permisos GPS/Bluetooth aunque el código los oculta; conviene una receta pública de mínimos si se publica con cuenta.

El AAB nuevo falló antes de completar por `Unable to establish loopback connection`. Se reintentó IPv4 y se obtuvo stacktrace de Gradle con `UnixDomainSockets.connect` / `Invalid argument`; el diagnóstico con Java de Android Studio mostró la misma causa. **Es un fallo observado en el entorno de comunicación de la JVM; no se obtuvo evidencia de un error Dart o compilación de la app. Aun así, no quedó validado un paquete nuevo.** No se cambió configuración global Java/Flutter para resolverlo.

El AAB preexistente sí devuelve `jar verified` y sus 18 bibliotecas pasan la inspección de ELF del script. La firma presenta avisos de certificado autofirmado/sin timestamp y lectura JarFile/JarInputStream: no equivalen por sí solos a rechazo de Play. La inspección no empareja ese archivo antiguo con un manifiesto generado después ni lo presenta como build de este árbol. Debe repetirse en el candidato final, incluyendo APK generado del bundle, firma, empaquetado/alineación y ejecución en 16 KB. [Guía Android](https://developer.android.com/guide/practices/page-sizes).

Falta completar en Console: datos del titular/cuenta, acceso a producción, política y soporte, Data safety, clasificación/público/anuncios y declaraciones aplicables, ficha y capturas del build final. Si es una cuenta personal nueva sujeta a prueba cerrada, Google pide 12 participantes inscritos durante 14 días consecutivos antes de solicitar producción; el estado real de tu cuenta no se comprobó. [Requisito oficial](https://support.google.com/googleplay/android-developer/answer/14151465).

El workflow actual corre análisis/tests y seguridad SQL, pero no construye/inspecciona un release Android. Añadir esa verificación y fijar herramientas. README y documentos anteriores aún citan versión/respaldo 9 y pruebas antiguas; actualizar la fuente de verdad al congelar candidato.

## Aceptación pendiente y orden de trabajo

1. **Integridad:** D01–D06; transformar las reproducciones en regresiones que fallen ante el defecto y pasen después de corregirlo.
2. **UI de captura:** errores de carga, pesaje de lote, borrado/edición en Finanzas, contraste, onboarding y recuperación accesible; cerrar D07/D08/U01–U04.
3. **Herramientas y candidato:** reparar los dos montajes de tests, completar compilación nueva, congelar versión/parámetros y conservar hash/evidencias del AAB final.
4. **Validación Android:** instalación limpia y actualización, arranque sin red, cámara/fotos denegadas, texto grande/teclado/oscuro, TalkBack, cierre forzado/poco espacio, datos de rancho grande y recuperación en instalación limpia. Verificar que una operación fallida no confirma éxito ni duplica al reintentar.
5. **Publicación:** configurar contacto/política, revisar ficha y declaraciones, subir a pruebas internas y atender el informe previo al lanzamiento; después completar la pista cerrada/producción que corresponda a la cuenta.

El teléfono conectado reportaba Android API 31, página 4 KB y LibretApp 0.1.2+5 instalada. Estaba en otra aplicación; solo se consultaron metadatos. No se navegó su contenido ni se sustituyó la instalación. Los datos de las reproducciones son ficticios. No hubo acceso a Play Console, envíos SMS, publicación ni pruebas nuevas contra producción. No se certifican iOS, web, todos los dispositivos ni ausencia total de errores.

## Registros y anexos

- [Backend y persistencia](backend.md).
- [UI y registros por módulo](ui-registros.md).
- [Seguridad y requisitos de publicación](publicacion-seguridad.md).
- [Hallazgos y criterios de cierre CSV](hallazgos.csv).
- [Pruebas ejecutadas por módulo CSV](resultados-por-modulo.csv).
- Evidencia estructurada: `../../artifacts/auditoria-2026-10-18/evidencia.json` y `test-summary.json`.
- Logs: `flutter-analyze.log`, `flutter-test.jsonl`, `backup-probe.log`, `backend_probe.log`, `ui-probe.log`, `scale-offline-probe.log`, `offline-gates.log`, `visual-profile.log`, `visual-onboarding.log`, `android-build.log`, `android-build-retry.log`, `gradle-diagnostic.log`, `gradle-jbr.log` y `aab-existente-signature.log` en esa carpeta de artefactos.
- Código reproducible de diagnóstico: `backup_probe_test.dart`, `backend_probe_test.dart`, `ui_probe_test.dart`, `scale_offline_probe_test.dart`; capturas nuevas en `visual/`. Los once casos pasan cuando **demuestran fallos actuales**; no deben contarse como once funciones aprobadas.
