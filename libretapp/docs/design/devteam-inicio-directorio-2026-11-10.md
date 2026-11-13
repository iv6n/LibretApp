# Inicio, Directorio y ficha animal · revisión DevTeam

10 de noviembre de 2026. LibretApp `0.1.4+27` offline debug instalada en OPPO CPH2123, modo demo con datos ficticios.

## Dirección y cambios

Claude Sonnet recibió las capturas previas y el contexto de código por DevTeam. Su [especificación](../../artifacts/devteam-review-2026-11-10/next/claude-report.json) ordenó compactar Inicio, densificar las tarjetas del Directorio y reducir la cabecera de la ficha. GPT contrastó las medidas con el código y aplicó las mejoras. DeepSeek se consultó en paralelo para riesgos QA, pero su [respuesta](../../artifacts/devteam-review-2026-11-10/next/deepseek-report.json) se cortó y no contiene hallazgos utilizables.

- **Inicio:** cabecera más corta, tarjeta Pendientes sin texto introductorio repetido, tres asuntos accionables compactos. Se conservaron rutas, datos, tarjetas configurables, orden y desactivaciones guardadas. La captura real ahora enseña el título y los totales de «Tus animales» bajo Pendientes.
- **Directorio:** nombre o alias primero, arete/especie/edad secundarios, avatar de 56 dp. Las etiquetas de estado se priorizan; las restantes se consultan mediante `+N`. Claude encontró que el contador de Wera saltaba solo a otra línea en la primera compilación. Se fijó a la misma fila, con desplazamiento horizontal de las etiquetas cuando hace falta. Filtros, búsqueda, menú, modo compacto y navegación se conservaron.
- **Ficha:** cabecera expandida más corta, ilustración de 64 dp, nombre/arete/edad/estado juntos y nombre visible al colapsar. Se conservan editar, actualizar, cinco pestañas y la acción de registro. El contenido reproductivo comienza antes en la pantalla. El marcador durante la carga de una ilustración sin foto usa un icono neutro.

La [galería comparativa](../../artifacts/devteam-review-2026-11-10/next/index.html) muestra las tres pantallas antes y después. La [revisión visual final de Claude](../../artifacts/devteam-review-2026-11-10/next/claude-final-report.json) aceptó Inicio y ficha, e identificó el salto del contador `+N`; la captura posterior [Directorio final](../../artifacts/devteam-review-2026-11-10/next/18-directorio-final.png) confirma la corrección. El JSON final de Claude llegó envuelto en Markdown, por lo que el adaptador no lo normalizó; su texto legible se revisó directamente.

## Verificación

La suite amplia de Inicio, Directorio y `test/app` se ejecutó inicialmente con **796 casos aprobados y 7 fallos**: seis expectativas del logotipo anterior de 24 dp y una prueba equina que intentaba tocar un chip fuera del área visible. Se actualizaron a la nueva medida de 20 dp y a desplazar el selector antes de tocarlo. La pasada final terminó con **843 pruebas aprobadas y cero fallos**. También aprobaron **113 pruebas focales** y **102 pruebas** de tarjetas/fichas para especies, tema claro/oscuro, 320, 360, 412, 600 y 1200 dp; a 320 dp se incluyó texto al 200 %. Estas cifras se solapan y no son una suma de casos únicos. El análisis estático focal y `git diff --check` quedaron limpios. El [log de la primera suite](../../artifacts/devteam-review-2026-11-10/next/regression-tests.log) conserva los fallos iniciales; el [log final](../../artifacts/devteam-review-2026-11-10/next/regression-tests-final.log) y el [log de tablet](../../artifacts/devteam-review-2026-11-10/next/tablet-layout-tests.log) conservan las aprobaciones.

En el móvil se observó Inicio con **133 pendientes**, tres asuntos y «Tus animales» visible; Directorio con **37 animales** y luego el filtro Bovino con **19**; buscar Nancy mostró **2 resultados**. La ficha de Nancy abrió Resumen, Cuidados y Registros. No se añadieron ni borraron registros de la demo en esta revisión. La app quedó en Inicio.

La lectura manual con TalkBack sigue pendiente; las pruebas de semántica y texto ampliado no la sustituyen. La sugerencia menor de Claude para una próxima iteración es revisar el color del estado activo de la barra inferior, tras comprobar primero el sistema de tema y los otros tabs.
