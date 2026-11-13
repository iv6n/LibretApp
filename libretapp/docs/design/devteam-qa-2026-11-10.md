# Revisión de registros y UI/UX con DevTeam · 10 de noviembre de 2026

## Cobertura y evidencia obtenida

La revisión se realizó sobre LibretApp en modo demo, con datos ficticios, en un OPPO CPH2123. La [galería local](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/index.html) contiene **11 capturas principales**: menú de registros, menú en Plantas, Peso, Sanitario, nueva tarea, Inicio, Directorio, ficha de vaca, Agenda, Reportes y Perfil. Esas capturas corresponden al estado previo de esta iteración; no representan por sí mismas una validación de los cambios posteriores.

La suite general terminó con **491 pruebas aprobadas y cero fallos**, abarcando registros, Inicio, Agenda, onboarding, Reportes, Perfil, cultivos, lotes, ubicaciones y `test/app`. Incluyó validaciones, persistencia y rollback, reintentos, navegación, teclado, SafeArea y escenarios con texto al 200 %. El resultado está en el [log de la suite](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/qa-suite.log).

Una comprobación focal adicional terminó con **10 pruebas aprobadas** entre [semántica de campos compartidos](C:/Code/LibretApp/libretapp/test/core/widgets/app_form_fields_semantics_test.dart) y [regresiones de accesibilidad offline](C:/Code/LibretApp/libretapp/test/regressions/offline_accessibility_ui_test.dart). La primera confirma que `AppTextField` expone su etiqueta en el árbol Semantics; la segunda cubre contraste, texto ampliado, layout y confirmaciones. Estas cifras describen la base revisada, no la validación final de la implementación siguiente.

## Ciclo manual de registro confirmado

Se realizó un ciclo real de **Peso para Nancy, 451 kg**, dentro de la demo:

| Paso observado | Evidencia |
| --- | --- |
| Guardar el peso y recibir la confirmación mediante snackbar | [Peso guardado](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/peso-guardado-qa.png) |
| Reabrir la ficha y ver «Último peso 451» en el resumen | [Resumen de Nancy](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/vaca-peso-qa.png) |
| Abrir Registros y encontrar el pesaje de 451 kg | [Registro persistido](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/registros-peso-qa.png) |
| Confirmar la eliminación únicamente del registro creado para QA | [Confirmación de eliminación](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/peso-eliminar-qa.png) y [estado posterior](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/peso-eliminado-qa.png) |

Este recorrido verifica ese caso concreto de guardado, lectura posterior y eliminación. No equivale a probar manualmente el guardado de todos los tipos de registro.

## Dirección de diseño y decisiones adoptadas

**Claude Sonnet dirigió la propuesta visual mediante DevTeam**, a partir de capturas reales de menú, Peso y tarea, junto con las fuentes del patrón compartido de formularios. El [reporte recibido](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/claude-design.json) conserva sus recomendaciones legibles, aunque el JSON interno tenía comillas mal escapadas y no pudo normalizarse como hallazgos estructurados. Las recomendaciones se contrastaron con el código antes de adoptarlas.

Las decisiones para esta iteración son:

1. Colocar Guardar y Cancelar en un **pie fijo de los formularios compartidos**, con espacio seguro para teclado, sistema y texto ampliado. Se conserva `AppRecordHeader`, conforme al orden de implementación del resumen de Claude, que difiere su retirada.
2. Priorizar **Añadir animal, Programar tarea y Peso** cuando ya existen animales. En primer uso se mantienen las acciones que pueden realizarse sin animales. Las demás funciones siguen en una expansión que informa su cantidad.
3. Usar **dos columnas desde 600 dp y tres desde 960 dp** en el menú, con tarjetas que permitan envolver el texto, y limitar la lectura de formularios a **640 dp**.
4. Usar el icono **`pets` en el selector de animal**; la búsqueda conserva su icono específico al desplegarse.

Fuentes de la intervención: [menú de registros](C:/Code/LibretApp/libretapp/lib/features/registro/view/registro_page.dart), [estructura de formularios](C:/Code/LibretApp/libretapp/lib/core/widgets/app_form_scaffold.dart), [cuerpo y acciones compartidas](C:/Code/LibretApp/libretapp/lib/core/widgets/app_form_body.dart) y [selector de animal](C:/Code/LibretApp/libretapp/lib/features/registro/widgets/animal_selector.dart).

Dos descripciones del reporte de Claude no se aceptaron como hechos del estado anterior: **el menú ya tenía agrupación y expansión**, y **los formularios ya estaban limitados a 720 dp**. Por tanto, esta intervención ajusta prioridades y cambia el máximo de 720 a 640 dp; no parte de una lista plana con diez acciones primarias ni de formularios a todo el ancho de una pantalla de 1200 dp.

Las demás pantallas capturadas quedan como evidencia y backlog para revisiones posteriores. No se afirma que Inicio, Directorio, ficha de vaca, Agenda, Reportes o Perfil hayan sido rediseñados en esta iteración.

## Límites de la evidencia

- **TalkBack manual sigue pendiente.** El `NAF=true` del XML de UI Automator no demuestra por sí solo una etiqueta perdida: los controles conservan `labelText` y el puente Android de Flutter exporta las etiquetas de campos editables mediante `hintText`. La prueba Semantics aprobada respalda el componente compartido, pero no sustituye la observación de un lector de pantalla en el teléfono.
- La respuesta de **DeepSeek no aportó contenido utilizable**; no se considera evidencia QA ni se le atribuyen hallazgos.
- El primer envío a Claude terminó por el timeout de 25 segundos y dejó una **reserva pendiente de conciliación** en el ledger. El reintento, preparado y aprobado de nuevo, sí devolvió la propuesta. El intento fallido no se cuenta como informe recibido.

## Nota técnica de DevTeam

La infraestructura ahora usa un timeout de inferencia de **120 segundos**, configurable mediante `DEVTEAM_REQUEST_TIMEOUT_MS` entre 1000 y 600000 ms. El [runner local](C:/Code/DevTeam/scripts/review-task.mjs) utiliza el mismo coordinador, allowlist, redacción, presupuesto y ledger; muestra la preparación y exige `approve:<taskId>` exacto por stdin antes del envío. La compilación y las **17 pruebas locales de DevTeam** aprobaron sin llamadas de red. Fuentes: [proveedores](C:/Code/DevTeam/src/providers.ts), [pruebas de timeout](C:/Code/DevTeam/tests/request_timeout.test.ts) y [pruebas de aprobación](C:/Code/DevTeam/tests/review_task.test.ts).

## Validación de implementación

La implementación terminó con **73 pruebas posteriores aprobadas**: 18 del menú, 31 de footer/layout/guardas y 24 de validación y flujo reproductivo. Son pruebas focales y de regresión; algunas repiten casos de la suite base, por lo que no deben sumarse como cobertura única. El análisis estático de los archivos modificados y `git diff --check` quedaron limpios. Logs: [footer](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/footer-tests.log) y [registros](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/footer-records-regression.log).

Se compiló e instaló **0.1.4+25 offline debug** en el OPPO conectado. La revisión real confirmó:

- Tres accesos principales y expansión con contador, sin perder las otras rutas. Plantas aparece antes en la lista.
- Guardar y Cancelar permanecen visibles **por encima del teclado**: [captura real](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/after/12-peso-teclado.png).
- Guardar sin animal muestra la validación y conserva el formulario: [validación](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/after/14-peso-validacion.png).
- La última tarjeta Nueva ubicación puede verse completa al desplazar el menú: [final de lista](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/after/13-menu-final.png).
- La app quedó en el menú, sin conservar el registro de peso creado para QA.

Evidencia de la entrega: [comparación antes/después](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/comparison.html), [galería posterior](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/after/index.html) y [APK instalado](C:/Code/LibretApp/libretapp/build/app/outputs/flutter-apk/app-offline-debug.apk). Las capturas posteriores de Inicio, Directorio, vaca, Agenda, Reportes y Perfil son las imágenes base reutilizadas para la revisión general; su interfaz no cambió en esta tanda.

## Revisión final de Claude y siguientes prioridades

Claude aceptó expresamente menú y Peso en su [revisión de las capturas posteriores](C:/Code/LibretApp/libretapp/artifacts/devteam-review-2026-11-10/claude-final-review.json), sin bloqueos observados. El adaptador no validó el JSON de esa respuesta porque el modelo utilizó una severidad no admitida; el texto completo de aceptación y las recomendaciones sí se conservó y fue revisado.

Su orden propuesto para la siguiente iteración es:

1. **Inicio:** mejorar lectura y jerarquía de las tarjetas de pendientes y animales. Verificar primero sus medidas y acciones actuales; reducir texto repetido, mantener títulos breves y exponer el siguiente cuidado relevante. Aceptación: el asunto y su acción se entienden al primer vistazo, áreas táctiles de al menos48dp y sin recortes al200%.
2. **Directorio y ficha animal:** unificar el tratamiento de tarjetas, avatares, chips y acciones con el sistema de la app. Propuesta de medidas de Claude: avatar48dp, nombre16sp, chips de texto mínimo12sp, separación8dp y secciones con padding16dp. Aceptación: identidad del animal y estado se distinguen claramente, con contraste suficiente y sin ocultar acciones.

Agenda, Reportes y Perfil quedan después en su orden. Estas son prioridades planificadas, no cambios implementados. Algunas afirmaciones de su segunda respuesta no quedan respaldadas por capturas: una imagen no demuestra incumplimiento de altura64dp ni comportamiento al200%, y la referencia a slate/teal y al cian22D3EE no coincide con la marca crema/verde existente. Antes de adoptar esas partes se deben contrastar con mediciones, código, contraste y la identidad visual; no se cuentan como defectos comprobados.
