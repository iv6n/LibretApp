# Estudio de apps de registro animal y recomendaciones para LibretApp

Fecha de consulta: 24 de octubre de 2026.

## Recomendación principal

Convertir LibretApp en una libreta ganadera que permita registrar rápido, conservar una historia confiable y saber qué hacer después con cada animal o lote. La prioridad es completar la conexión entre los módulos existentes: un tratamiento debe actualizar el historial, el inventario, el costo y la próxima tarea; un parto debe relacionar a la madre, las crías y el seguimiento posterior.

Para el primer mercado propongo productores de bovinos en México, con opciones para carne, leche y doble propósito. Es una hipótesis de enfoque basada en el proyecto actual, que debe contrastarse con productores. Mantener la arquitectura multiespecie permite crecer después hacia ovinos y caprinos, sin exigir que todos utilicen formularios de bovinos.

## Alcance y método

Se compararon ocho productos mediante páginas de sus fabricantes y centros de ayuda. La consulta combina páginas abiertas y extractos indexados de fuentes oficiales. Se contrastó esa información con el README vigente, el registro de funciones y una lectura selectiva del código de LibretApp.

Esta es una comparación de funciones publicadas y necesidades de producto. No se instalaron las ocho apps, no se probaron sus planes de pago, no se entrevistó a usuarios y no se midió su confiabilidad. Tampoco se ejecutó LibretApp ni se repitió su suite de pruebas durante este estudio. Una función publicada por un proveedor no acredita por sí sola su calidad en campo; una función no mencionada aquí puede existir en su producto.

No se asignan cuotas de mercado, posiciones de liderazgo ni puntuaciones de calidad sin evidencia. Las prioridades, esfuerzos y propuestas siguientes son recomendaciones propias. Los precios concretos quedan fuera del estudio porque el objetivo es decidir qué construir.

## Comparación de productos

| Producto y enfoque | Funciones publicadas relevantes | Qué tomaría para LibretApp |
|---|---|---|
| [Herdwatch — bovinos](https://herdwatch.com/solutions/cattle-management-software/) | Registro de partos, reproducción, tratamientos, pesajes y ganancia diaria; trabajo sin conexión; importación de hojas de cálculo; lectores electrónicos y básculas. | Captura rápida en campo y una historia que acompañe al animal durante todo su ciclo. |
| [CattleMax — gestión bovina](https://www.cattlemax.com/) y [TagMax](https://www.cattlemax.com/tagmax) | Inventario, sanidad, reproducción, destetes, reportes e integraciones. TagMax distingue sesiones de captura sin conexión y un modo de consulta de CattleMax que requiere conexión. | Separar la sesión de trabajo en el corral de la consulta administrativa; publicar compatibilidad por equipo. |
| [AgriWebb — gestión del rancho](https://www.agriwebb.com/) | Ganado, pastoreo, tareas, inventario, equipo de trabajo y análisis de insumos frente a resultados. | Relacionar animal, ubicación, alimento y costo para apoyar decisiones de manejo. |
| [Livestocked — varias especies](https://www.livestocked.com/) | Manejo multiespecie, operación con y sin conexión, potreros, tareas, contabilidad operativa, inventarios, proyecciones y conexión de equipos. | Una base común con módulos que se adapten al tipo de explotación. |
| [Farmbrite — explotación diversificada](https://help.farmbrite.com/help/livestock) | Registros configurables, genealogía, tratamientos, alimentación, costos y reportes. Su [glosario de grupos](https://help.farmbrite.com/help/farmbrite-glossary) distingue grupos seleccionados, grupos por filtros y conjuntos sin identificación individual. | Grupos inteligentes y registro por cantidad, además de los lotes de animales identificados. |
| [UNIFORM-Agri — lechería](https://www.uniform-agri.com/us/solutions/uniform-management-app/) | Captura de eventos sin conexión, indicadores, listas de acciones y revisiones veterinarias, varios dispositivos, salud y producción de leche. | Pantallas orientadas al trabajo del día y mayor profundidad cuando el usuario activa el modo lechero. |
| [Identigan — identificación y mercado latinoamericano](https://www.identigan.com/app-ganadera/mexico) | Lectores RFID, inventario, básculas Bluetooth, pesajes, sanidad, reproducción y uso sin conexión. Presenta una oferta orientada a México. | Facilitar el uso del identificador que el productor ya tiene, con soporte comprobable de lectores. |
| [MiGanado — manejo cotidiano del hato](https://miganado.app/) | Ficha, genealogía, sanidad, reproducción, ordeño, reportes y sincronización según su página oficial. Publica una oferta gratuita. | Mantener accesibles las tareas básicas y lograr una primera experiencia útil con pocos datos. |

Las funciones y conexiones pueden depender del plan y del país. Las integraciones con registros oficiales de otros mercados no deben interpretarse como integraciones mexicanas.

### Lo que sugiere la comparación

El registro de animales, sanidad, reproducción y peso aparece repetidamente en la muestra. Lo considero una base competitiva. La oportunidad para LibretApp está en reducir el tiempo de captura y conectar esa información con tareas y resultados económicos.

La documentación de [sincronización de AgriWebb](https://help.agriwebb.com/en/articles/6828757-syncing-the-mobile-app-best-practice) muestra que la operación entre dispositivos también necesita estados visibles, identidades de usuario y procedimientos claros para resolver diferencias. Recomiendo tratar la sincronización como una función que el productor pueda entender y comprobar.

La gratuidad publicada por [MiGanado](https://miganado.app/) y la entrada gratuita limitada publicada por [Identigan](https://www.identigan.com/app-ganadera/mexico) sugieren presión sobre el cobro por una ficha básica. Mi hipótesis comercial es cobrar por colaboración, análisis e integraciones que ahorren trabajo de forma demostrable.

## Qué tiene ya LibretApp y dónde están las brechas

El estado siguiente procede del árbol local revisado. «Existe» significa que se encontró código o documentación concreta, sin certificar su uso en producción.

| Área | Evidencia local | Recomendación |
|---|---|---|
| Núcleo ganadero y operación local | El [README](../README.md) describe animales, lotes, ubicaciones, registros, agenda, personal, ordeño y finanzas. El [candidato bovino](bovinos/README.md) documenta reproducción, vínculos de crías, destete, pesajes y conservación de historia. | Consolidar los recorridos completos y verificar con usuarios dónde hay pasos repetidos. |
| Identificación e importación | [AnimalIdentificationService](../lib/features/directorio/animales/domain/animal_identification.dart) contiene identificadores tipados, validación y vista previa de duplicados. El [importador Excel](../lib/core/services/animal_excel_import_service.dart) revisado procesa columnas básicas, relaciona por arete y puede actualizar animales existentes. No se encontró una llamada a `previewImport` desde ese importador. | Integrar una sola experiencia de importación: mapear columnas, previsualizar, resolver coincidencias y confirmar altas o actualizaciones. |
| Respaldo y sincronización | El [README](../README.md) distingue recuperación mediante copias de sincronización. Hay [motor de sincronización](../lib/core/sync/sync_engine.dart) y modelos de finca y roles. Los [controles de versión](../lib/core/platform/release_features.dart) deshabilitan la sincronización en las ediciones públicas. | Completar el servicio remoto y la experiencia entre dispositivos antes de anunciar colaboración disponible. |
| Lectores y básculas | La [configuración nativa](../lib/core/di/injection_native.dart) registra un lector simulado. La báscula utiliza simulación o un adaptador no disponible. Existe una [abstracción Bluetooth](../lib/features/rfid/infrastructure/rfid_transport.dart). | Elegir un lector y una báscula concretos y completar su conexión física, reconexión y recuperación de sesiones. |
| Sanidad y retiro | [HealthRecord](../lib/features/directorio/animales/domain/entities/health_record.dart) ya guarda lote del medicamento, días de retiro y fecha de finalización. | Ampliar y comprobar el efecto del retiro en ordeño, alertas y comercialización; evitar duplicar el módulo sanitario. |
| Alimento e inventario | [FeedService](../lib/features/directorio/lotes/alimentacion/feed_service.dart) relaciona consumo con movimientos de inventario. El [registro de funciones](FEATURE_REGISTER.md) señala validación local y otros recorridos pendientes. | Completar el recorrido compra → almacén → aplicación/consumo → costo → reporte, incluyendo correcciones. |
| Informes para México | El [catálogo](../lib/features/reportes/mexico/mexico_report_models.dart) define columnas y versiones para movimientos, morbilidad y mortalidad; el conector oficial permanece deshabilitado. | Validar los formatos y presentar los documentos como informes operativos mientras no exista una integración oficial comprobada. |
| Varias especies y lotes | El [enum de especies](../lib/features/directorio/animales/domain/enums/species.dart) incluye bovinos, caprinos, ovinos, porcinos, équidos, aves, caninos y otros. [LoteEntity](../lib/features/directorio/lotes/domain/entities/lote_entity.dart) agrupa UUID de animales. | Añadir manejo por cantidad para las operaciones que no identifican cada animal. Incluir especies en una lista no sustituye sus flujos específicos. |

## Funciones que recomiendo completar o implementar

### 1. Registro e importación que ahorren tiempo — prioridad inmediata

- Alta breve con identificación local o existente, especie y los datos mínimos necesarios. Completar después raza, origen, foto y detalles productivos.
- Fecha de nacimiento exacta, estimada o desconocida; conservar esa precisión en cálculos y exportaciones.
- Importación Excel/CSV con asignación de columnas, vista previa, errores por fila y comparación de valores antes de actualizar.
- Conservar ceros iniciales de aretes y códigos; no tratar identificadores como cantidades.
- Separar «crear», «actualizar» y «omitir», con resumen del resultado y recuperación ante interrupciones.

Objetivo propuesto de aceptación: un productor familiarizado debe poder dar un alta básica en menos de 30 segundos. Es una meta para medir en campo, no un resultado obtenido.

### 2. Sesiones de trabajo y registros colectivos — prioridad inmediata

Un modo de corral debería permitir elegir una actividad, conservar fecha/producto/responsable y recorrer animales sin volver al inicio. Debe mostrar animales procesados, omitidos y pendientes, permitir corregir una lectura y reanudar tras cerrar la aplicación.

Ejemplos: vacunar un lote, pesar los animales que pasan por la manga o mover un grupo de potrero. Cada aplicación debe quedar en la historia de sus animales, con una sesión común que permita revisar el trabajo completo. Si cambia la composición del lote después, el evento debe conservar a sus participantes originales.

### 3. Historia confiable y continuidad sin señal — prioridad inmediata

- Una línea de tiempo por animal con nacimientos, pesajes, servicios, tratamientos, movimientos, ventas y bajas.
- Correcciones con fecha, autor y motivo, además de la fecha en que ocurrió el evento.
- Indicadores claros de guardado local, datos pendientes, sincronización y conflictos.
- Recuperación comprobada en otro teléfono, con fotografías y relaciones familiares.
- Identidades estables y reintentos que no dupliquen tratamientos, crías o gastos.

La prueba central: capturar una jornada en modo avión, cerrar la app, volver a abrirla y recuperar el trabajo. Para colaboración, añadir dos teléfonos que editan información mientras están desconectados.

### 4. Un inicio que diga qué hacer hoy — prioridad inmediata

Mostrar tareas concretas con acceso al animal o lote: próximas aplicaciones, revisiones reproductivas, partos estimados, retiros activos, animales pendientes de pesaje y productos por agotarse.

Cada aviso debe tener fecha, responsable, estado y una acción para resolverlo. Los umbrales deben ser configurables. Distinguir «sin diagnóstico registrado» de un diagnóstico negativo y «fecha esperada» de un parto confirmado.

Añadir filtros guardados que se actualicen solos: hembras pendientes de revisión, animales bajo retiro, crías próximas al destete o animales sin pesaje reciente. Farmbrite documenta este patrón de [grupos por criterios](https://help.farmbrite.com/help/farmbrite-glossary).

### 5. Sanidad conectada con almacén y producción — siguiente etapa

Completar el flujo desde producto, lote, caducidad y existencia hasta su aplicación, costo, historial y próxima tarea. Registrar tratamientos individuales y colectivos con unidades y responsables consistentes.

Recomiendo permitir retiros diferenciados para leche y carne cuando correspondan al producto y uso registrados, y calcularlos desde la última aplicación pertinente. El sistema debe registrar el origen del plazo utilizado. El productor debe poder identificar qué animales o producción tienen una restricción registrada antes de comercializar.

Al corregir o anular una aplicación, recalcular el inventario, el costo y las tareas vinculadas sin perder la trazabilidad del cambio.

### 6. Reproducción completa por especie — siguiente etapa

Consolidar el ciclo celo → servicio o inseminación → diagnóstico → parto → crías → destete. Admitir parto sin servicio conocido, varios servicios, correcciones y partos múltiples según la especie.

Los protocolos de inseminación a tiempo fijo deben generar tareas con responsables y permitir registrar ejecución, retraso o cancelación. Conectar material genético, lote, proveedor y consumo cuando el usuario utilice esa función.

La genealogía debe conservar padres desconocidos y mostrar sus límites. Cualquier indicador genético posterior debe distinguir información incompleta de un resultado favorable. Para bovinos, LibretApp ya tiene una parte sustancial de este ciclo: conviene profundizar lo existente.

### 7. Producción, alimento y rentabilidad — siguiente etapa

- Pesajes medidos y estimados claramente diferenciados; curvas y ganancia diaria basadas en intervalos válidos.
- Alimentación servida, sobrantes, consumo calculado, ingredientes y costos con unidades consistentes.
- Costo por animal y lote, incluyendo compras y gastos directos, con reglas explícitas para distribuir gastos compartidos.
- Margen realizado de ventas separado de proyecciones de valor o de margen.
- Para leche: sesiones, días en leche, secado, producción descartada y litros comercializados; calidad si hay datos reales para registrarla.

La ganancia diaria utiliza la diferencia entre dos pesos válidos dividida entre los días transcurridos. La conversión alimenticia requiere consumos y ganancias del mismo grupo y periodo, con una base de alimento claramente definida. Si faltan datos, mostrar «información insuficiente» y la cobertura del cálculo.

Ejemplo de decisión útil: «Este lote aumenta de peso, pero el costo por kilogramo ganado está por encima del objetivo», acompañado de los registros y supuestos utilizados.

### 8. Colaboración real y varias fincas — siguiente etapa

Completar el recorrido de invitación, aceptación, permisos y revocación para propietario, administrador, trabajador y veterinario. Los modelos de rol ya existen en [farm_models.dart](../lib/core/tenancy/farm_models.dart); falta evaluar el recorrido completo con servicio remoto y usuarios reales.

Separar fincas y conservar quién registró cada evento. Permitir asignar tareas y limitar el acceso a información económica. Los permisos deben aplicarse en el servicio remoto y en el manejo local, con un comportamiento definido cuando un equipo permanece desconectado.

No usar restauraciones manuales de respaldo como mecanismo cotidiano de colaboración. Son recorridos con propósitos y expectativas distintos.

### 9. Identificación, movimientos e informes mexicanos — siguiente etapa

Mantener identificadores internos estables, aretes visuales y electrónicos, sus reemplazos y las referencias oficiales que aporte el productor. La UPP corresponde a la unidad de producción; debe vincularse a la finca y a los movimientos pertinentes, sin utilizarse como identificador único de cada animal. Véanse la [definición oficial de UPP](https://dof.gob.mx/normasOficiales/5689/sagarpa12_C/sagarpa12_C.html) y la [inscripción al Padrón Ganadero Nacional](https://www.gob.mx/agricultura/acciones-y-programas/inscripcion-al-padron-ganadero-nacional).

Preparar expedientes de movimientos con origen, destino, animales, fecha y documentos adjuntos. Los reportes necesitan filtros, versión del formato y distinción entre información capturada y verificación oficial.

SENASICA describe la identificación y trazabilidad a lo largo de las etapas del animal en su [información oficial de identificación animal](https://www.gob.mx/senasica/acciones-y-programas/identificacion-animal-353020). La cobertura exacta y las conexiones de LibretApp deben validarse con los procedimientos aplicables antes de anunciar emisión de trámites o documentos oficiales.

### 10. Equipos y pastoreo — expansión operativa

Comenzar por un lector y una báscula utilizados por productores del segmento elegido. Publicar marca, modelo y versiones comprobadas. Probar lecturas repetidas, peso estable, pérdida de Bluetooth, reconexión y recuperación de sesiones.

El registro de un movimiento indica una ubicación conocida o declarada. El seguimiento continuo necesita un dispositivo y una fuente de datos específicos. La lectura RFID por sí sola no aporta ubicación GPS.

Para potreros: mapa, superficie, ocupación, entradas y salidas, descanso y registros de disponibilidad de alimento. Completar primero la relación entre movimientos y ocupación antes de añadir proyecciones de carga o alertas complejas.

### 11. Multiespecie con flujos propios — expansión por demanda

| Especie o manejo | Funciones específicas sugeridas |
|---|---|
| Bovinos | Cría, engorda, lechería y doble propósito con indicadores por objetivo. |
| Ovinos y caprinos | Partos múltiples, relación de varias crías, manejo del rebaño y seguimiento reproductivo configurable. |
| Porcinos | Camadas, nacidos vivos, bajas, adopciones entre camadas, destete y lotes de engorda. |
| Aves | Parvadas por cantidad, mortalidad, consumo, producción de huevo o peso de salida. |
| Équidos | Identificación, reproducción, trabajo y cuidados específicos, como herraje, si existe demanda. |

Crear una entidad para conjuntos contables: existencias iniciales, entradas, nacimientos, salidas, bajas y ajustes justificados. Diferenciar ese conjunto de un lote que agrupa animales identificados. Considerar divisiones y uniones de grupos conservando origen e historia.

### 12. Voz, fotografía e inteligencia artificial — etapa posterior

Los primeros usos que recomiendo son transcribir notas, leer aretes y pesos de una libreta fotografiada, proponer correspondencias de columnas y responder consultas con enlaces a registros del rancho.

El flujo debe mostrar lo interpretado, permitir corrección y guardar después de revisión. Conservar la fuente y la confianza cuando corresponda. Medir errores y tiempo ahorrado frente a la captura actual antes de ampliar el alcance.

La facturación fiscal, los pagos, los sensores continuos y los análisis genéticos avanzados deben añadirse cuando el segmento y la demanda los justifiquen. Su presencia como adaptador o modelo local no los convierte en una prioridad comercial.

## Orden de implementación recomendado

Los esfuerzos son relativos para el estado revisado: medio implica integrar y pulir varias piezas existentes; alto implica servicio remoto, equipos o cambios importantes del modelo. No son estimaciones de calendario.

| Etapa | Entrega principal | Esfuerzo relativo | Condición para avanzar |
|---|---|---|---|
| 1. Captura y confianza | Importación con vista previa, sesiones colectivas, recorridos bovinos completos, tareas de hoy y recuperación. | Medio | Jornada real sin señal, correcciones y recuperación en otro teléfono verificadas. |
| 2. Operación conectada | Sincronización entre dispositivos, roles, conflictos, grupos inteligentes y conexión sanidad/alimento/inventario/costos. | Alto | Dos usuarios pueden trabajar sin conexión y resolver diferencias sin pérdidas ni duplicados. |
| 3. Profundidad por actividad | Reproducción y lechería avanzadas, equipos concretos, movimientos e informes mexicanos, pastoreo. | Alto | Cada integración tiene evidencia de funcionamiento con su equipo, proveedor o formato real. |
| 4. Expansión | Conjuntos por cantidad, siguientes especies, voz, lectura de libretas y otras integraciones elegidas por demanda. | Alto y variable | El piloto demuestra uso recurrente y ahorro de trabajo del núcleo. |

El enfoque de especies puede alterar el orden: si el primer cliente objetivo maneja aves o porcinos, el modelo de conjuntos o camadas pasa a la primera etapa.

## Cómo validar que la app está completa para su usuario

Recomiendo un piloto con productores de carne, leche y doble propósito, un trabajador y un veterinario, dentro del segmento inicial elegido. Es una propuesta de investigación; no se realizaron esas entrevistas en este estudio.

Evaluar tareas completas: importar el hato; corregir un animal; registrar un parto y sus crías; vacunar un lote; pesar animales; moverlos; registrar una venta; revisar costos y recuperar información en otro equipo.

Medir tiempo y errores por tarea, necesidad de ayuda, uso semanal, avisos resueltos, datos pendientes y conflictos. Para los cálculos, medir también cuánto del hato tiene información suficiente. La retención de productores y el ahorro de trabajo aportarán más evidencia comercial que el número de módulos del menú.

Como criterios de aceptación propuestos: cero registros perdidos en las pruebas de interrupción, cero duplicados causados por reintentos en los escenarios probados y reconstrucción de inventario y genealogía tras restaurar. Estos criterios deben comprobarse en escenarios definidos; no constituyen una garantía universal.

## Experiencia y modelo comercial sugeridos

Mantener navegación breve, búsqueda por arete o nombre, botones legibles bajo el sol, formularios adaptados a especie y objetivo, y un resumen diario que abra directamente la acción pendiente. Las funciones avanzadas deben aparecer en el contexto donde se necesitan.

Propongo una base accesible con registro local, historia, agenda y exportación. Evaluar planes de pago por colaboración, varias fincas, análisis e integraciones comprobadas. Preservar una vía clara para recuperar y llevarse los datos. Este modelo es una hipótesis propia que debe validarse con disposición real de pago.

La próxima entrega que recomiendo para LibretApp es concreta: **importar el hato con revisión previa, trabajar por sesiones sin señal y terminar cada jornada con historia, inventario, costos y pendientes coherentes**.
