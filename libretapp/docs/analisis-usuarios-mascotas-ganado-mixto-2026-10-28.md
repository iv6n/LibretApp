**Análisis de uso de LibretApp: mascotas, ganado y ambos**

28 de octubre de 2026 · Revisión del código disponible en este espacio de trabajo.

La recomendación principal es mantener **una sola aplicación con tres configuraciones iniciales: Mascotas, Ganado y Ambos**. Cada configuración debe preparar Inicio, accesos y formularios para la actividad del usuario y permitir ajustes posteriores. Un animal conserva una sola ficha y un solo historial aunque aparezca en varias vistas.

Este documento combina hallazgos del código, propuestas de producto y criterios de aceptación. Los recorridos y tiempos propuestos son hipótesis para probar con personas; no representan resultados de un estudio de usuarios. La revisión no acredita el comportamiento de una versión instalada ni la entrega de notificaciones en un teléfono real.

**1. Punto de partida real**

La documentación anterior describe las experiencias Completa y Lite. El código actual declara una experiencia unificada y conserva las opciones antiguas para compatibilidad. Las preferencias actuales priorizan especies y plantas sin filtrar las fichas guardadas. Conviene actualizar esos documentos antes de utilizar sus pendientes como una lista de funciones faltantes.

| Área | Lo que ya existe en el código revisado | Mejora necesaria |
| --- | --- | --- |
| Personalización | Preferencias por especie y plantas; secciones del Directorio configurables; tarjetas y acciones de Inicio configurables. | Coordinar esas decisiones desde una configuración común y ofrecer valores iniciales para cada caso. |
| Mascotas | Perros y gatos; propósito Compañía; tarjeta específica; datos de salud, peso, fotos y costos. | Hacer que el recorrido general sea tan sencillo como la tarjeta y admitir compañía en otras especies. |
| Ganado | Lotes, ubicaciones, reproducción, producción, importación revisada y sesiones de pesaje, sanidad y movimientos por lotes. | Destacar las operaciones pertinentes por actividad y facilitar reanudar el trabajo de campo. |
| Registros | Las acciones desde una ficha ya consideran especie, sexo, propósito y estado. | Aplicar la misma lógica al menú general, que ofrece destete, ordeña e importación de hato sin adaptar su contenido al perfil. |
| Inicio | Pendientes, resumen, clima y personalización. | Adaptar los bloques que hoy quedan fijos: acceso a registrar mascota, resumen del rancho y sugerencias de crear lotes y ubicaciones. |
| Agenda | Actividades, recordatorios sanitarios y reproductivos, y composición de citas o tomas domésticas. | Asegurar la convivencia de todos los orígenes y dar a programar, registrar y completar significados consistentes. |
| Protección de datos | Respaldo completo, recuperación y capacidades de nube sujetas a configuración de la distribución. | Explicar con claridad qué está guardado en el dispositivo, qué tiene una copia externa y cuándo se verificó su recuperación. |

Fuentes: [preferencias](../lib/core/experience/registration_preferences.dart), [experiencia unificada](../lib/core/experience/app_experience.dart), [Directorio](../lib/features/directorio/data/directorio_config_repository.dart), [Inicio](../lib/features/inicio/view/inicio_view.dart), [acciones por animal](../lib/features/directorio/animales/domain/services/animal_record_actions.dart), [menú general](../lib/features/registro/view/registro_page.dart) y [operación por lotes](etapa-1-hato-y-lotes.md).

**2. Persona con mascota: recordar cuidados y encontrar su información**

Ejemplo: una persona con una perra y un gato que usa la app ocasionalmente, con mayor frecuencia durante un tratamiento. Su primera necesidad es saber qué toca hacer y consultar lo que ya ocurrió.

Primer uso propuesto: elegir Mascotas, seleccionar perro o gato, escribir un nombre o alias y guardar. Foto, raza, identificación, sexo y edad pueden completarse después; la edad debe admitir «No lo sé». Al terminar, ofrecer una acción concreta: «Programar cuidado», «Registrar atención» o «Añadir otra mascota».

Uso cotidiano: abrir Inicio y ver primero las tareas de hoy, los pendientes vencidos y las próximas citas. Una actividad debe mostrar mascota, fecha y acción. Desde ella se puede registrar lo realizado, posponerlo o cancelarlo; abrir una notificación nunca debe marcar una toma como administrada.

Uso ocasional: consultar vacunas y atenciones anteriores, agregar una receta o estudio, revisar peso y gastos, preparar un resumen para una consulta y recuperar la información al cambiar de teléfono.

La ficha inicial debería presentar foto, nombre, siguiente cuidado y último registro relevante. Raza, microchip, contactos y documentos pueden estar en detalles. Lotes, ordeña y datos del rancho no necesitan ocupar sus accesos iniciales. Plantas debe ser una opción independiente.

Las mejoras con mayor valor son un historial sanitario fácil de leer, recordatorios fiables, documentos y contacto veterinario, y gastos por mascota reutilizando el registro de costos existente. Las indicaciones y horarios de tratamientos los captura la persona según su pauta; la aplicación organiza su seguimiento.

**3. Persona con ganado: capturar rápido y conservar trazabilidad**

Ejemplo: un productor con bovinos organizados en varios lotes, que trabaja con poca señal y registra pesajes, tratamientos y movimientos. También debe funcionar para quien tiene pocos animales y prefiere registrarlos individualmente.

Primer uso propuesto: elegir Ganado, indicar especies y, opcionalmente, actividad —cría, leche, engorda u otra—. Después puede registrar un animal, importar su listado o crear un lote. Los datos personales y del rancho deben seguir siendo opcionales para empezar. La app puede sugerir un lote cuando resulte útil, sin exigir completar toda la estructura antes de guardar el primer animal.

Uso cotidiano: revisar pendientes, abrir el lote que va a atender, registrar la operación, revisar participantes y confirmar. Si se interrumpe el trabajo, Inicio debe ofrecer «Continuar captura» con el lote, tipo de sesión y avance. La funcionalidad de borradores y confirmación por lotes ya existe; el trabajo propuesto es hacerla visible y consistente.

Uso ocasional: altas, nacimientos, destetes, ventas, movimientos, reproducción, producción y reportes. Los accesos deben adaptarse a la actividad: una explotación de engorda puede priorizar pesajes y costos; una lechera, ordeña y reproducción.

En campo conviene una lista compacta con identificación, nombre si existe, lote y situación relevante. Búsqueda por arete o alias, teclado numérico para pesos, valores comunes por sesión y excepciones por animal reducen la captura repetida. Antes de confirmar se deben distinguir seleccionados, omitidos y registros inválidos.

Sanidad ya contiene lote del medicamento y datos de retiro. La mejora consiste en integrar esos datos en el seguimiento operativo y las alertas aplicables a leche o salida de animales, conservando quién registró la información y su origen. No hace falta crear otro historial sanitario.

**4. Persona con ambos: cuidar por separado y consultar en conjunto**

Ejemplo: una familia con mascotas, un hato y perros de trabajo. Necesita una agenda conjunta, acceso rápido a cada grupo y gastos comprensibles.

Debe poder registrar mascotas y ganado en el mismo espacio, sin repetir el alta ni cambiar de cuenta. Propongo un selector visible «Todos / Mascotas / Ganado», con grupos personales adicionales si se necesitan. Es un filtro de consulta: no cambia los permisos, la propiedad ni los datos de los animales.

La agenda conjunta debe conservar cada actividad una sola vez. Si un perro participa en la vida familiar y en el rancho, su cuidado puede aparecer en ambas vistas conservando la misma identidad y estado. Una tarea que incluya varios grupos debe mostrar sus participantes y seguir accesible desde Todos.

Las cifras deben indicar su alcance. «2 mascotas y 38 animales de producción» es más informativo que «40 animales» en un panel de rendimiento. Los costos se asignan al animal o grupo correspondiente; un gasto compartido se registra una sola vez y puede distribuirse, sin duplicar su importe en el total.

La especie por sí sola no determina el uso. Un caballo puede ser de compañía, deporte o trabajo; un perro puede ser de compañía y de guardia. El modelo ya contiene propósitos como Compañía, Trabajo, Guardia y Deporte: conviene aprovecharlos y permitir grupos adicionales cuando un solo propósito no exprese el caso.

| Decisión de interfaz | Mascotas | Ganado | Ambos |
| --- | --- | --- | --- |
| Prioridad en Inicio | Cuidados de hoy y próximas citas. | Pendientes de operación y capturas por continuar. | Pendientes conjuntos con grupo y animal visibles. |
| Vista de animales | Tarjetas con foto y nombre. | Lista compacta y acceso a lotes. | Vistas guardadas por grupo. |
| Acciones iniciales | Registrar atención, programar cuidado, peso y gasto. | Pesaje, sanidad, movimiento y actividad productiva pertinente. | Acciones según la selección actual. |
| Reportes | Historial y gastos por mascota. | Hato, sanidad, producción y costos. | Resúmenes separados y consolidado con alcance explícito. |
| Nivel de detalle | Básico al comenzar. | Básico o detallado según la operación. | Ajustable por actividad y ficha. |

**5. Reglas para que resulte fácil de manejar**

1. Mantener la ubicación de los destinos principales. Inicio, Animales, Agenda, Resúmenes y Ajustes son nombres a evaluar; las configuraciones cambian prioridades dentro de ellos. «Registrar» debe ser una acción visible y consistente.
2. Dar a cada formulario una acción principal clara. Usar «Registrar lo realizado» para hechos y «Programar» para actividades futuras. Una tarea completada debe enlazar al hecho registrado cuando corresponda, evitando capturarlo dos veces.
3. Mostrar primero los campos mínimos y después «Más detalles». Conservar lo escrito al ampliar el formulario y al corregir un error. En mascotas se puede pedir un nombre o alias; en ganado, permitir identificación pendiente con un identificador interno estable.
4. Aceptar información desconocida. Edad, sexo o antecedentes no informados deben seguir siendo desconocidos. «Sin vacuna registrada» y «Vacuna vencida» requieren estados y mensajes diferentes.
5. Ofrecer una configuración inicial útil sin exigir personalización. En Ajustes, permitir activar módulos, ordenar accesos y elegir lista o tarjetas. Aplicar otra configuración sugerida debe mostrar qué cambiará y conservar las decisiones manuales que la persona quiera mantener.
6. Mantener acceso a Todos y «Ver todas las funciones». Ocultar un acceso nunca elimina registros ni su historial. Al filtrar, indicar «Mostrando mascotas» o el alcance elegido.
7. Confirmar el guardado real y conservar borradores cuando falle. Para trabajo sin conexión, la propuesta es guardar primero localmente y gestionar los servicios remotos según su disponibilidad, consistente con la [guía de arquitectura de Android](https://developer.android.com/topic/architecture/data-layer/offline-first).
8. Usar etiquetas visibles, ejemplos breves y errores junto al campo. Explicar «arete» o «UPP» cuando aparezcan, evitando pedirlos fuera de contexto. Esta propuesta sigue el criterio de [etiquetas e instrucciones de W3C](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions.html).
9. Mejorar la legibilidad de la navegación, que actualmente usa textos de 9–10 en su estilo. Comprobar áreas táctiles de al menos 48 × 48 en Android, texto ampliado, contraste, TalkBack y acciones que no dependan solo del color. La [guía de Flutter](https://docs.flutter.dev/ui/accessibility) respalda estas comprobaciones. Se requiere validación visual y con lector de pantalla para evaluar el resultado.

**6. Implementaciones y correcciones por prioridad**

P0 significa resolver antes de ampliar la experiencia de estos tres públicos; P1 consolida su uso cotidiano; P2 permite crecer después de validar lo esencial. El orden expresa impacto propuesto, no una estimación de esfuerzo.

| Prioridad | Trabajo | Resultado comprobable |
| --- | --- | --- |
| P0 | Preservar citas y tomas domésticas al regenerar la agenda general. | Abrir o actualizar Agenda conserva identificadores, estados y fechas; no pierde pendientes ni duplica avisos. |
| P0 | Corregir el tratamiento de datos desconocidos en altas e indicadores. | Un sexo no informado no suma como hembra; una edad desconocida no se convierte en cero; ausencia de antecedentes no afirma una condición sanitaria. |
| P0 | Configuraciones Mascotas, Ganado y Ambos, con política común para Inicio y registros. | Un usuario de mascotas obtiene cuidados y citas como accesos iniciales; uno ganadero obtiene sus operaciones frecuentes. |
| P0 | Proteger y explicar la recuperación de datos. | Se identifica la última copia externa disponible y se verifica restauración de fichas, fotos, historial, agenda y borradores en otro espacio. |
| P1 | Clasificación por propósito y grupos; selector de alcance compartido. | Directorio, Agenda y Resúmenes aplican criterios consistentes sin duplicar animales ni importes. |
| P1 | Unificar programar, ejecutar, posponer y cancelar. | La actividad y el registro real se enlazan; editar o cancelar un plan actualiza solo sus ocurrencias futuras aplicables. |
| P1 | Completar la ficha cotidiana de mascota. | Salud, peso, costos, contactos y documentos se consultan desde una misma ficha, con datos mínimos al comenzar. |
| P1 | Hacer visible la continuidad del trabajo por lotes. | Un borrador reaparece al reabrir; confirmar repetidamente una sesión conserva un único comprobante y registros únicos. |
| P1 | Ajustar accesibilidad y mensajes en recorridos completos. | Se pueden terminar altas, cuidados y capturas con texto al 200 %, teclado abierto y TalkBack. |
| P2 | Colaboración familiar o de rancho con permisos efectivos. | Responsable, colaborador y lector tienen acceso definido; dos personas no registran dos veces la misma ejecución. |
| P2 | Sincronización entre dispositivos y resolución de conflictos. | Se prueban desconexión, ediciones simultáneas y recuperación; acceder con el mismo teléfono no se presenta como recuperación automática de datos. |
| P2 | RFID, básculas, mapas y captura por voz. | Se incorporan donde reduzcan trabajo medido. La voz propone datos para revisar antes de guardar. |

Las funciones de colaboración, sincronización y hardware tienen piezas existentes y restricciones por distribución. Deben completarse y comprobarse en su recorrido real antes de presentarlas como disponibles. [Capacidades de publicación](../lib/core/platform/release_features.dart).

**7. Hallazgos que merecen atención antes de desarrollar más módulos**

**Agenda doméstica y general.** `LiteTaskComposer` crea citas y tomas con `sourceType: 'lite'`. `AgendaReminderSyncService` considera automática cualquier entrada con origen distinto de `manual`, pero su regeneración no reconstruye las entradas Lite. Por ello, un pendiente de ese origen puede quedar fuera de la lista que se escribe al terminar. La carga de Agenda invoca ese servicio. La comprobación aislada y su alcance se documentan en la nota de validación al final.

La corrección propuesta es identificar explícitamente los orígenes que el servicio puede regenerar y preservar los demás, incluidos los futuros que todavía no conozca. Después se necesita una prueba del recorrido crear recordatorio → abrir Agenda → reiniciar → completar, incluyendo tomas de un mismo plan. Fuentes: [composición](../lib/features/lite/lite_task_composer.dart), [reconciliación](../lib/features/agenda/data/agenda_reminder_sync_service.dart) y [carga](../lib/features/agenda/bloc/agenda_bloc.dart).

**Indicadores con información incompleta.** El resumen por categoría suma como hembra cualquier sexo distinto de macho; incluye así `Sex.unknown`. También calcula animales sin vacunación a partir de un booleano, aunque el mensaje diga «sin vacuna registrada». Se recomienda separar desconocido, registrado y vencido según los datos que existan, y añadir una categoría explícita de sexo no informado. [Servicio de Inicio](../lib/features/inicio/data/inicio_dashboard_service.dart).

**Adaptación parcial.** La configuración inicial del Directorio deduce necesidad de lotes y ubicaciones a partir de cualquier especie distinta de perro o gato. Esto puede resultar excesivo para un caballo o ave de compañía. Además, Inicio tiene elementos fijos fuera de la lista de tarjetas configurables. Conviene calcular las sugerencias desde la intención elegida y el propósito, preservando la personalización explícita. [Configuración del Directorio](../lib/features/directorio/data/directorio_config_repository.dart) y [vista de Inicio](../lib/features/inicio/view/inicio_view.dart).

**Alta rápida y edad.** Existe soporte para edad desconocida en la ficha y en el servicio doméstico, mientras el alta rápida calcula una fecha estimada desde su control de edad. Hay que verificar y unificar el comportamiento de ambas entradas antes de prometer que dejar la edad vacía conserva «Sin dato». [Alta rápida](../lib/features/directorio/animales/view/quick_register_animal_page.dart) y [servicio de mascotas](../lib/features/lite/lite_pet_service.dart).

**8. Cómo validar que la propuesta funciona**

Propongo comenzar con cinco personas de cada grupo, incluyendo personas con poca experiencia digital y al menos algunas que usen texto ampliado. Se observan tareas reales con datos ficticios; después se itera y se vuelve a probar. Esta muestra sirve para encontrar fricciones, no para afirmar facilidad universal.

| Escenario | Tarea | Meta inicial propuesta |
| --- | --- | --- |
| Mascotas | Dar de alta una mascota con edad desconocida y programar una cita. | Completar sin ayuda; alta en menos de un minuto y cita en menos de 30 segundos desde la ficha. |
| Ganado | Abrir un lote, guardar parte de un pesaje, cerrar y reanudar sin red. | Recuperar participantes y datos; cero pérdidas y cero duplicados al confirmar. |
| Ambos | Localizar una mascota, consultar una tarea del ganado y revisar gastos de cada grupo. | Entender el alcance activo y volver a Todos sin cambiar de cuenta ni repetir registros. |
| Personalización | Activar un módulo, cambiar la vista y regresar a la configuración previa. | Completar sin ayuda, conservando todos los datos. |
| Recordatorios | Crear una cita y varias tomas; abrir Agenda, editar el plan y reiniciar. | Conservar estados e historial, sin actividades desaparecidas ni avisos duplicados. |
| Recuperación | Restaurar una copia en un espacio de prueba. | Recuperar fichas, medios, historiales, pendientes y borradores compatibles; distinguir copia de sincronización. |

Medir también errores, solicitudes de ayuda, abandono antes del primer guardado y comprensión de los mensajes. Los tiempos anteriores son metas de diseño que deben ajustarse a la observación.

La primera entrega recomendada reúne las correcciones P0 y una configuración inicial coherente para los tres casos. Después, los resultados de las pruebas permiten decidir si aporta más valor mejorar el expediente de mascotas, la captura de campo o la colaboración.

**Nota de validación técnica de esta revisión**

Se ejecutaron **38 pruebas existentes**, todas aprobadas, sobre preferencias, acciones por animal y notificaciones. Se ejecutó también **un sondeo de caracterización** que confirmó el defecto de conservación: tras llamar al servicio real de reconciliación con repositorios en memoria, la cita doméstica pendiente pasó de **1 a 0** y la cita de control con origen manual permaneció en **1**.

El sondeo aprueba porque afirma el comportamiento observado del defecto; no es una prueba de aceptación de funcionamiento correcto. Utiliza una cita doméstica sin animal asociado, admitida por el formulario. No reproduce la interacción completa de pantallas ni verifica alarmas en un dispositivo. Las tomas comparten el origen implicado, pero su recorrido completo necesita una regresión específica después de corregirlo.

Evidencia reproducible: [sondeo Dart](../artifacts/usage-analysis-2026-10-28/agenda_probe_test.dart) y [resultado y alcance](../artifacts/usage-analysis-2026-10-28/resultado.txt). Las pruebas usan datos ficticios y no modifican los registros reales. No se modificó código funcional durante este análisis.
