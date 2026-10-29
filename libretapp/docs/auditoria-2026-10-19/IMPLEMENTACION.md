# LibretApp: correcciones y aceptación del piloto offline

Fecha: 19 de octubre de 2026. Alcance: Android offline, invitado y demo,
`app.libret`, versión prevista `0.1.3+6`, respaldo esquema 11. Se conservó el
árbol de cambios locales; no se publicó ni se desplegó Supabase.

**El paquete de QA no constituye aprobación de tienda.** La aceptación física,
los datos reales del responsable y los requisitos externos de Play siguen
siendo condiciones de salida. El estado actualizado de cada hallazgo está en
[cierres.csv](cierres.csv); el diagnóstico original se conserva en
[la auditoría del 18 de octubre](../auditoria-2026-10-18/INFORME.md).

## Integridad y recuperación

- Restauración moderna y antigua mediante transacción Isar: preparación de IDs,
  limpieza, importación, migraciones, perfil y validación del resultado. Un
  almacén antiguo sin capacidad transaccional se rechaza antes de escribir.
- Validación de estructura, números finitos, aretes normalizados duplicados,
  identidades y referencias; Merge conserva las correcciones locales más
  recientes cuando existen fechas de modificación. Se rechazan formatos futuros.
- Perfil por espacio en Isar: migración idempotente de `perfil_v1` que conserva
  el origen. Los formatos antiguos preservan campos omitidos; un respaldo sin
  perfil no lo borra.
- Fotografías preparadas en un directorio exclusivo por importación, con rutas
  estrictas y SHA-256; un fallo no sobrescribe los medios anteriores.
- Pesaje masivo en una transacción, UUID estable por captura, reintento
  idempotente y conflicto visible si cambia el contenido. Fecha, selección,
  captura y salida quedan bloqueadas durante el guardado; el fallo conserva
  los campos para reintentar.
- Procedencia de ubicación y cinco marcas sanitarias manuales. Corregir o
  borrar un registro recalcula lo derivado. Los indicadores antiguos de origen
  desconocido se conservan y se ofrecen a revisión explícita.
- Altas y edición de animales comparten una transacción con sus movimientos,
  pertenencia a lotes y registros dependientes. Los recordatorios se actualizan
  después del commit. La ubicación inicial almacena su identidad estable.
- Colisión de finca/tipo para un UUID rechazada en Isar, Drift y restauración.
  El kardex comprueba identidad, existencia y saldo dentro de la transacción;
  los traslados acreditan destino y conservan cantidad y valoración totales.

## Corrección y UI

- Finanzas permite editar manteniendo ID/UUID, registra `updatedAt` para Merge
  y confirma el borrado. NaN/Infinity se rechazan en formularios, importación
  y persistencia; importes históricos inválidos aparecen como incidencias y
  hacen visible que el resumen es parcial.
- Cinco formularios de edición muestran error de lectura y reintento.
- La inyección pública usa una báscula no disponible; botón y acción tienen
  protección. El piloto ofrece invitado/demo y oculta cuentas/SMS, nube,
  hardware, pagos y GPS. Reportes pendientes y avisos del sistema no se
  anuncian como funciones disponibles.
- La paleta oscura y la selección usan texto con referencia de contraste
  mínima 4.5:1. Se verifican tamaños de 320/360/412 dp, texto al 200 %, teclado,
  carga, error y confirmación. Los renders de widgets usan la fuente de prueba
  de Flutter; las capturas Android se conservan por separado.
- La comprobación visual del APK añadió correcciones de Inicio: prioridad y
  contador legibles en oscuro, resumen que permite varias líneas y navegación
  sin etiquetas superpuestas al 200 %. La acción central conserva su icono,
  nombre accesible y ayuda cuando el texto grande requiere ocultar su etiqueta.
- Ajustes incluye revisión de datos y copias de recuperación: listado,
  exportación y restauración. La limpieza no escribe en la vista previa,
  requiere selección/confirmación, revalida el estado y crea primero una copia
  nativa con `Isar.copyToFile`, medios y manifiesto. Aplica todos los cambios
  elegidos en una transacción y recalcula indicadores.
- No hay fusión automática de animales ni genealogías. Referencias ambiguas
  requieren revisión individual. Los importes inválidos exigen un valor válido
  o eliminación explícita. Una copia nativa conserva incluso valores que JSON
  no puede representar y restaura solo en el mismo espacio/dispositivo.
  `.libretbackup` sigue siendo el formato portátil.

## Android y herramientas

Se fijó Flutter 3.47.5 y Java 17 en CI. Hay compilación e inspección de AAB con
firma de QA separada de la firma privada, y una matriz de integración nativa
para API 28 y API 36 con páginas de 16 KB. La ejecución de esos jobs en GitHub
quedará acreditada por sus resultados, no por haber escrito el workflow.

Se aisló el fallo de comunicación Java/Gradle en Windows mediante una opción
de proceso que hace que OpenJDK use su alternativa TCP para sus pipes internos;
no se deshabilitó ninguna protección de la base ni se cambió la configuración
global. El generador aplica esa opción solo a la compilación hija.

**El piloto requiere Android 9/API 28.** La prueba de Android 7/API 24 falló al
abrir Isar porque su kernel 3.10 es incompatible con libmdbx actual. La
[confirmación del proveedor](https://github.com/isar-community/isar-community/issues/48#issuecomment-3345226005)
indica kernel 3.16 o posterior. No se anuló esa protección: el mínimo probado
del piloto se elevó a API 28 (kernel 4.4 en el emulador de aceptación). Esto
excluye equipos Android 7/8 del nuevo piloto; una instalación antigua en esos
equipos no recibirá esta actualización incompatible.

Para regenerar modelos se utiliza `python tool/regenerate_models.py`. El
wrapper preserva el archivo Drift mantenido por separado y ejecuta el grafo
completo de Isar; no deben emplearse filtros parciales que eliminen otros
modelos generados.

## Resultado final local

- Suite completa: **1,193 aprobadas, 0 fallidas** (piloto offline).
- Analizador: **0 errores, 0 advertencias, 248 avisos informativos** de estilo no bloqueantes.
- Integración nativa y reapertura tras cierre del proceso: aprobadas en API 28
  y API 36/16 KB. Se usa `--no-uninstall` para conservar los datos entre pruebas.
- AAB y APK QA: firma verificada; APK alineado con `zipalign -c -P 16 -v 4`;
  manifiesto real del AAB comprobado con bundletool. Instalación conservando
  datos ficticios y reapertura tras cierre forzado verificadas en ambos emuladores.
- SHA-256 del AAB: `5e604a5cca184a5a008df1e4db345330ce99ab4c6351db1f34f0976c9464ffe3`.
- SHA-256 del APK: `d4452cad089067cc5ddbdd74762ba857c3d7a29b975ecc6ea23de44efa7548f2`.
- La evidencia estructurada está en `acceptance.json`; contiene explícitamente
  los controles físicos y de firma histórica pendientes. `readyForStore` es **false**.

## Evidencia verificable

Los logs, capturas y paquetes están en `artifacts/implementacion-2026-10-19/`
(excluido de Git). Los datos utilizados son ficticios y los emuladores fueron
dedicados a QA. No se alteró la base de un teléfono de usuario.

| Área | Evidencia |
| --- | --- |
| Suite completa, incluido piloto offline | `full-suite-accepted.log` |
| Análisis estático | `flutter-analyze-accepted.log` |
| Rollback de edición y recuperación nativa | `atomic-workflows-final.log` |
| Once reproducciones convertidas a regresiones y ampliaciones | `test/regressions/` y suite completa |
| Compatibilidad con base Isar 3.1 y respaldos anteriores | `test/core/database/isar_legacy_compatibility_test.dart`, `test/core/backup/`, suite completa |
| UI, texto grande y contraste | `test/regressions/offline_accessibility_ui_test.dart`, suite completa, `ui/` |
| Integración nativa Android mínimo | `android-integration-api28-verified.log` |
| Integración nativa Android 16 KB | `android-integration-16kb-verified.log` |
| Bloqueos del generador de tienda | `candidate-gates.log` |
| Compilación, manifiesto, ELF, firma y SHA-256 | `candidate-qa/` |
| Instalación, actualización y cierre forzado | `android-package-acceptance.json` y logs asociados |

Los intentos fallidos/intermedios se conservan con número de intento para
trazabilidad. No sustituyen los resultados finales ni se cuentan como aprobados.

## Condiciones que siguen pendientes

1. Aceptación física con TalkBack, permisos rechazados, teclado, rendimiento y
   cierre forzado en equipos reales. Los resultados del emulador y los tests de
   widgets no equivalen a esta aceptación.
2. Responsable real, correo de soporte, política HTTPS publicada y mayor
   código de versión en Console. El generador de tienda rechaza datos de prueba,
   aceptación incompleta o evidencia de otra revisión del código.
3. Verificar la actualización desde una versión realmente distribuida con su
   certificado histórico o el de Play App Signing. La prueba local con firma de
   QA no acredita una firma histórica desconocida.
4. Verificación de cuenta, ficha, declaraciones, informe previo al lanzamiento
   y la [prueba cerrada aplicable de 12 participantes durante 14 días consecutivos](https://support.google.com/googleplay/android-developer/answer/14151465).
5. SQL/RLS preparados pero no ejecutados contra Supabase local por ausencia de
   Docker operativo. La nube permanece deshabilitada; su aceptación y despliegue
   están fuera del piloto. Cuentas/SMS, sincronización, hardware y paridad web
   no se consideran terminados ni se habilitan en esta entrega.

No se marca el candidato como listo para tienda mientras falte cualquiera de
sus condiciones técnicas. No se realizó publicación en producción.
