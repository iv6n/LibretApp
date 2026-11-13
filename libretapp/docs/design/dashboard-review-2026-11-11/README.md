# Revisión de Inicio en móvil — 11 de noviembre de 2026

Dispositivo: OPPO CPH2123 conectado por ADB durante la revisión, 1080 × 2400 px a densidad 480 (360 × 800 dp). Versión observada: LibretApp en modo demo, Rancho El Mezquite. Las capturas y la maqueta documentan el estado anterior a los cambios de código descritos al final. No se modificaron los datos del dispositivo.

## Evidencia

| Recorrido | Captura | Observación |
| --- | --- | --- |
| Entrada | [01 · inicio](01-inicio.png) | Pendientes ocupa casi todo el primer viewport; el total es 133. |
| Animales y accesos | [02 · animales](2-desplazamiento.png) | Cuatro métricas, dos animales recientes y tres botones de alta/búsqueda preceden los accesos. |
| Agenda | [03 · partos y eventos](3-desplazamiento.png) | Dos partos y actividades del mismo día aparecen varias pantallas abajo. |
| Operación | [04 · finanzas y ubicaciones](4-desplazamiento.png) | Balance y ubicaciones están bajo la agenda; los importes laterales no tienen rótulo. |
| Final | [05 · biblioteca y clima](5-desplazamiento.png) | Biblioteca consume una tarjeta completa; el clima demo no aporta avisos reales. |
| Configuración | [07 · personalizar](07-personalizar.png) | La cabecera desborda 29 px a la derecha en este equipo. |

## Diagnóstico, ordenado por impacto

1. **La carga de trabajo no se puede interpretar de un vistazo.** El contador «133» reúne alertas, actividades vencidas y otras tareas; solo se ven tres. La lista prioriza todos los vencidos antes de los de hoy (`_buildTodayCareItems`), de modo que el día actual puede quedar escondido. Se debe agrupar por «Atención», «Hoy» y «Vencidos» con recuentos diferenciados y accesos filtrados. No calcular estos recuentos con los tres elementos visibles.
2. **La primera pantalla no ofrece un camino claro para actuar.** En 360 dp la tarjeta Pendientes mide aproximadamente 330 dp de alto; luego empieza una tarjeta de animales de más de 400 dp. Las actividades del día, partos, finanzas y ubicaciones requieren varios desplazamientos. Mostrar primero lo urgente y lo de hoy, seguidos de una fila de acciones.
3. **Hay duplicación de navegación.** «2 por revisar» repite la alerta de dos animales; «Añadir animal/mascota» convive con el botón fijo «Registrar»; la cuadrícula de cinco accesos ocupa otra pantalla. El resumen de animales debe ser una línea de estado enlazada al Directorio y el alta quedar en «Registrar». Dejar tres accesos contextuales y «Más».
4. **Algunas etiquetas inducen a error.** «Parto próximo (21 días)» aparece con «Vencida desde…» porque la actividad de Agenda venció; «Próximos partos» después muestra fechas futuras. Separar «Aviso de parto vencido» de «Parto estimado» y, si la fecha de parto es estimada, expresarlo así. Rotular «Ingresos» y «Gastos» junto a los importes del balance. Traducir «Pasture» a «Potrero» o al tipo local correcto.
5. **Personalización tiene un defecto de layout.** El encabezado «Personalizar inicio / Aplicar sugerida / cerrar» no cabe: Flutter muestra `RIGHT OVERFLOWED BY 29 PIXELS`. Poner la sugerencia en otra fila o en el menú; probar con escala de texto aumentada. La hoja ofrece activar acciones de alta que no se muestran en la cuadrícula porque Inicio las filtra, así que debe explicar que se muestran como botones principales o unificar la configuración.

## Propuesta de pantalla inicial

Ver [maqueta móvil](propuesta-inicio.png) y [fuente SVG](propuesta-inicio.svg). Es una dirección visual, no una captura de la app ni una afirmación sobre conteos de tareas de hoy.

| Posición | Contenido y acción | Altura orientativa |
| --- | --- | ---: |
| Cabecera | Saludo, rancho y fecha en dos líneas; demo discreto. | 64–76 dp |
| Resumen | 37 animales, 2 por revisar, 133 pendientes abiertos. Cada cifra abre una lista filtrada y explica qué cuenta. | 68–80 dp |
| Atender primero | Hasta dos asuntos distintos; estado, nombre, fecha y destino explícitos. «Ver pendientes» abre Agenda con filtro pertinente; si mezcla tipos, abrir una lista unificada. | 150–190 dp |
| Hoy | Dos próximas actividades con hora/fecha y «Ver agenda de hoy». Si todo está vencido, mantener Hoy visible aunque el contador sea cero. | 130–170 dp |
| Acciones | Buscar, Sanidad, Peso y Más; alta y otros registros desde el botón fijo Registrar. | 72–90 dp |
| Más abajo | Partos estimados, finanzas con ingresos/gastos rotulados y ubicaciones; registros recientes y biblioteca en una sección secundaria o configurables. Clima solo si existe ubicación y un aviso útil. | variable |

**Estilo:** conservar verde bosque y crema, fondo más claro y tarjetas menos altas; un solo color de advertencia por nivel de urgencia. Títulos de 16–18 sp, texto operativo de 14–16 sp, superficies táctiles de al menos 48 × 48 dp. Evitar texto informativo repetido debajo de los títulos. La barra inferior debe dejar el contenido visible con padding seguro.

**Comportamiento:** el contador grande abre una vista que muestre los 133 elementos, con grupos y filtros. Cada tarjeta lleva al animal o actividad exacta, no a la portada de una sección. La lista «Hoy» y las alertas se actualizan al volver a Inicio; cada estado vacío muestra una acción clara. Las preferencias ya guardadas de orden y visibilidad deben migrar sin perderse.

**Criterios para validar una implementación:** en este OPPO a 360 dp se ven cabecera, resumen, asuntos prioritarios y al menos el inicio de Hoy sin desplazarse; ningún `RenderFlex overflow` en 320/360/412 dp ni con texto al 200 %; una tarea de hoy es accesible aun con muchos vencidos; al pulsar cada contador se ven los registros que lo componen; personalización permite entender dónde aparece cada acceso; mascotas, ganado, perfil mixto y estado sin animales muestran contenido pertinente.

## Alcance de la revisión

Capturas reales y lectura de `inicio_view.dart`, `inicio_dashboard_service.dart`, `dashboard_widget_config.dart`, `quick_action_grid.dart` y `dashboard_customize_sheet.dart`. No se modificaron datos ni configuración del teléfono. Un segundo intento con DevTeam/Claude devolvió hallazgos parciales sobre la prioridad de Hoy, el desbordamiento de la hoja de personalización y las etiquetas ambiguas; se contrastaron con las capturas y el código.

## Implementación y validación

- Inicio muestra hasta una alerta prioritaria y dos actividades de hoy en la vista previa. El contador «Ver N» abre todos los asuntos agrupados en Atención, Hoy, Vencidos y Otros asuntos; cada elemento conserva su destino. Los avisos de parto vencidos se rotulan como avisos para distinguirlos de la fecha estimada del parto.
- El resumen de animales ocupa menos altura y deja los animales actualizados contraídos. «Registrar» concentra las altas, mientras «Buscar en directorio» queda como acceso principal. Los accesos rápidos usan tres columnas en anchuras normales y dos con poco espacio o texto grande. Finanzas muestra rótulos de ingresos y gastos; el tipo `Pasture` se presenta como «Potrero».
- La hoja de personalización separa el título y «Aplicar sugerida», permite desplazar las dos listas y conserva el orden y visibilidad guardados. Se corrigió el desbordamiento de la cabecera.
- Verificación local del 12 de noviembre: las 61 pruebas de `test/features/inicio` aprobaron y `flutter analyze` no encontró problemas en `inicio_view.dart` ni `quick_action_grid.dart`. Se corrigieron la repetición del título de una actividad vencida en la vista previa y el desbordamiento de Acciones frecuentes con texto ampliado. La maqueta SVG/PNG sigue siendo una dirección visual, no una captura de esta implementación.
- APK de revisión: `build/app/outputs/flutter-apk/app-offline-debug.apk`, `0.1.4+43`, paquete `app.libret`, SHA-256 `D74327193FAC34DAC6671C655CEF78512B5F856E43F741A8F403910A805066F5`. El OPPO (`4TDEHA8P8HZTK7BE`) tiene `0.1.4+41`; la firma debug del APK 43 coincide con la huella debug documentada para el dispositivo. El APK 43 aún no se instala ni se ha revisado visualmente en el teléfono. Cuando el teléfono esté disponible, actualizar en sitio con `adb -s 4TDEHA8P8HZTK7BE install -r build/app/outputs/flutter-apk/app-offline-debug.apk`, sin desinstalar ni borrar el escenario demo, y revisar Inicio, Directorio y ficha animal.
- Toolchain Android actualizado para Flutter 3.47.9: Gradle 9.3.1, AGP 9.1.0 y KGP 2.4.0. `flutter analyze --suggestions` reporta la combinación compatible y el APK offline debug se construyó correctamente. Se conserva `android.builtInKotlin=false` mientras `workmanager_android` siga aplicando KGP; Flutter advierte que esa dependencia deberá migrar antes de una futura versión del SDK. El bloque Kotlin DSL `android {}` se mantiene en `app/build.gradle.kts` para que Flutter CLI detecte el namespace al resolver el manifiesto antes del build; el target de JVM ya usa `kotlin.compilerOptions`.
