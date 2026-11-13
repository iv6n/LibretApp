# Pulido final Android — registro de hallazgos

Este registro usa tareas y observaciones actuales. Un hallazgo visto en código
no equivale a una prueba en un teléfono ni a una observación de usuarios.

## Estado inicial

- Se retiraron 1,115 imágenes antiguas de evidencia y propuestas de interfaz:
  6 de `artifacts/`, 954 de `libretapp/artifacts/`, 70 de `outputs/`,
  47 de directorios de diseño, 1 mockup y 37 vistas de `build/`.
- Se retiraron además 23 imágenes de ejemplo en carpetas `screenshots` de
  cachés Dart locales; el barrido final no encuentra capturas con esos nombres
  en el árbol del proyecto.
- Se conservaron ilustraciones, iconos, fotos de producto y estudios de iconos.
- Los hallazgos históricos útiles siguen descritos en texto; sus capturas ya no
  acreditan el estado actual del código.

## Hallazgos preliminares de código

| Tarea | Comportamiento observado | Impacto | Cambio | Verificación |
| --- | --- | --- | --- | --- |
| Elegir cómo empezar | El acceso telefónico inactivo ocupaba una acción principal y añadía un aviso. | Competía con invitado y demo. | Ocultarlo cuando no está habilitado y dar prioridad visual a invitado. | Prueba de onboarding; recorrido Android pendiente. |
| Registrar por primera vez | La ilustración y un párrafo precedían a las acciones en Inicio compacto. | La primera acción bajaba en pantalla. | Poner las acciones antes de la ilustración y quitar el párrafo. | Prueba a 320 dp y texto 200 %; teléfono pendiente. |
| Abrir Inicio | Un saludo genérico formaba otra cabecera antes de la primera tarea cuando el perfil no tenía nombre. | Ocupaba espacio sin aportar estado ni acción. | Mostrar el nombre solo si está configurado; conservar fecha y finca. | Prueba de cabecera y OPPO final aprobados. |
| Empezar en un rancho | El Inicio de invitado destacaba «Añadir mascota» y dejaba «Añadir animal» como acción secundaria. | La jerarquía no seguía el uso principal del piloto. | Destacar el alta de animal por defecto y en uso mixto; mantener mascota principal para un perfil de mascotas. | Prueba de Inicio y APK normal pendientes. |
| Terminar la primera alta | El enlace de respaldo quedaba recortado al borde inferior de la hoja de confirmación en el emulador de 412 dp. | El siguiente paso de protección no era visible ni fácil de tocar. | Dar a la hoja la altura necesaria y abreviar el enlace a «Ver respaldos». | Revisión en APK normal pendiente. |
| Volver tras el alta | «Volver al directorio» regresaba a la pantalla que abrió el formulario; desde Inicio terminaba en Inicio. | La etiqueta prometía un destino incorrecto y añadía un desvío. | Abrir explícitamente Animales en Directorio. | Revisión en APK actualizado pendiente. |
| Encontrar una ficha incompleta | Una ficha recién guardada repetía «Desconocido», «Sin dato», «DESCONOCIDO» y mostraba riesgo «Bajo» sin evaluación de salud. | Ocultaba el arete y podía sugerir una evaluación inexistente. | Mostrar datos conocidos, ubicación y pendientes accionables; ocultar campos neutros y la pastilla de riesgo bajo sin evaluación. | Prueba de tarjeta compacta; revisión en APK actualizado pendiente. |
| Consultar una mascota | En el OPPO, la tarjeta de una mascota nombrada mostraba «Edad sin dato · Sin dato» y una pastilla neutra de salud. | Repetía ausencias y alargaba la tarjeta. | Mostrar edad y sexo solo si se conocen; reservar el pie para ubicación o salud que requiera atención. | Prueba de mascota y OPPO final aprobados. |
| Abrir la ficha | La cabecera repetía «Sin identificación» y dos «Sin dato»; Resumen añadía nacimiento desconocido y una invitación larga. En el APK actualizado seguían una tarjeta que repetía «Completar ficha», identificación casi vacía, perfil de mascota con ausencias y valores neutros de riesgo y ubicación. | La información real y la acción quedaban entre vacíos. | Mostrar hechos conocidos, conservar especie y estado sanitario, dejar una sola acción para completar, ocultar filas sin datos y riesgos neutros. | 54 variantes de ficha y OPPO final aprobados. |
| Elegir registro | Cada tarjeta repetía su nombre en un subtítulo explicativo. | Menor densidad útil y más lectura. | Mostrar una etiqueta de acción por tarjeta. | Pruebas de menú y TalkBack pendientes. |
| Abrir Agenda vacía | Dos títulos, dos mensajes y la ilustración ocupaban el estado vacío; en el OPPO quedaba un enlace secundario redundante. El primer pulido retiró también la ilustración, que el titular quiere conservar. | La acción quedaba lejos del encabezado; al quitar toda la imagen se perdió la referencia visual del calendario. | Conservar la ilustración original con un solo título y una acción; retirar los mensajes y el enlace secundario. | 53 pruebas enfocadas aprobadas; en el OPPO se vio la ilustración con «Hoy no hay actividades» y «Programar actividad» tras instalar el nuevo APK. |
| Programar trabajo | En el OPPO, «Prioridad» precedía al título obligatorio y «Guardar tarea» quedaba fuera de la vista con el teclado abierto. | Costaba encontrar el primer dato y la acción final. | Poner «Título» al inicio y fijar «Guardar tarea» bajo el formulario de pantalla completa; conservar el desplazamiento en la hoja. | Prueba de 360 dp y OPPO con teclado abierto aprobados; el botón mostró validación sin guardar. |
| Abrir Reportes sin animales | La vista ofrecía registro y exportación sin datos. | La exportación era prematura. | Mostrar solo el primer registro. | Prueba de estado vacío; teléfono pendiente. |
| Leer Reportes con animales | La cabecera repetía total y pendientes; el OPPO también mostraba «Próximos partos: 0» para un espacio con una mascota. | Los bloques vacíos quitaban espacio a los datos útiles. | Retirar la cabecera y mostrar métricas de pendientes, vacunas y partos solo si tienen resultados. | Prueba de reportes y OPPO final aprobados. |
| Revisar respaldos | En el OPPO, la tarjeta de estado repetía que los datos estaban en el dispositivo y que se podía trabajar sin conexión. | El estado de la última copia y la acción de exportar bajaban en pantalla. | Mostrar fecha o ausencia de copia y una indicación breve de recuperación. | OPPO final: estado, exportación e importación visibles; no se restauraron datos personales. |
| Revisar Perfil | Una categoría genérica ocupaba el lugar del nombre de finca ausente. | Parecía un dato real. | Mostrar la finca solo si existe. | Prueba de perfil y TalkBack pendientes. |
| Abrir Directorio vacío | Animales, lotes, cultivos y ubicaciones presentaban frases de bienvenida antes de la acción; los filtros aparecían sin registros. En el OPPO, «Sin lotes» aún mostraba su ilustración, pero más pequeña que antes. | Las frases retrasaban el alta; la ilustración perdió presencia. | Dejar un título y una acción, ocultar filtros sin contenido y restaurar la ilustración a 136 dp con tarjeta de 384 dp. | 53 pruebas enfocadas aprobadas; la ilustración de «Sin lotes» se vio con su tamaño anterior en el APK nuevo del OPPO. |
| Desplazarse al final de Directorio y Agenda | En el OPPO, un degradado gris opaco cubría la zona detrás de «Nuevo» y de la barra flotante; el fondo de la barra ocupaba todo el ancho. | La franja cortaba visualmente ambas pantallas y ocultaba contenido al desplazarse. | Quitar el degradado y el fondo de ancho completo del contenedor común; conservar el espacio final para que tarjetas y acciones sigan siendo tocables. | En el APK nuevo del OPPO se vieron Lotes, Agenda y Animales con «Nuevo» sin franja; las capturas temporales se eliminaron. Las 53 pruebas enfocadas confirman que las listas pueden extenderse detrás de la barra y dejan las últimas acciones tocables. Una lista poblada y desplazada en el teléfono sigue pendiente. |
| Filtrar Directorio sin resultados | La vista repetía en un mensaje lo que ya indicaban el título y «Limpiar filtros». | Lectura adicional sin una decisión nueva. | Conservar el estado y la acción de limpiar. | Pruebas de filtros pendientes. |
| Buscar en Directorio | La búsqueda sin término mostraba un título y una explicación; cada resultado repetía su tipo debajo del nombre aunque ya estaba agrupado por tipo. | Más texto sin nueva información y menos espacio para resultados. | Dejar la búsqueda vacía hasta escribir; mantener grupo, nombre y conteo, anunciar el tipo con el nombre al lector de pantalla y conservar detalles de fuentes que fallen. | Prueba de búsqueda y TalkBack pendientes. |
| Reabrir la app sin conexión | `flutter test` desinstala el APK al terminar; la segunda invocación no encontró el registro del espacio de prueba. | Ese comando no puede acreditar persistencia entre procesos. | Comprobarla con el APK normal instalado y reinicio mediante ADB. | APK normal: forzar cierre y reabrir conservó el registro; la restauración nativa en una misma ejecución pasó. |
| Consultar la cobertura del piloto | 27 filas enlazaban a 32 imágenes ya retiradas; algunos recorridos figuraban como Android verificado solo por esas imágenes. | La matriz podía sugerir evidencia visual o validación actual inexistente. | Sustituir rutas por pruebas y observaciones textuales verificables; marcar el resto para revalidación. | Búsqueda de extensiones de imágenes en la matriz: cero; 70 filas conservadas. |
| Preparar actualización de Play | El OPPO tiene `app.libret` 0.1.4+20 con certificado debug SHA-256 `f7fb3f8f21b49bb4ebdc9c7fd08669817617ac47bf02978fa2fe21f6352b02f2`. Console muestra firma de instalación `86b5a6f2550562b6e9ee84c2912b07240c775e37a79d2d9bf955320a92b13e95`; la clave de subida local es `7f1c12465e5b9985db26166476dcab48f12d35cafeca11660e467268250fdfa4`. | Android no acepta una actualización directa con la firma de Play sobre el APK debug. | Exportar y verificar una copia, ensayar restauración fuera del teléfono y revisar la transición antes de desinstalar. | Las huellas se leyeron del APK instalado, keystore local y Console; transición pendiente. |
| Revisar la pista de Play | Console indica `app.libret` como borrador; prueba interna inactiva, sin versiones, y explorador de app bundles sin archivos. | El supuesto de una versión previa cargada no está confirmado; no hay código mayor visible. | Tomar 0 como mayor código visible de Console y generar al menos 21; revalidar al crear el lanzamiento. | Lectura de Panel de control, Prueba interna, Últimas versiones y explorador de bundles el 3 de noviembre; ninguna subida realizada. |
| Verificar permisos de la variante instalada | El APK `offlineDebug` del OPPO declara `INTERNET` para las herramientas de desarrollo de Flutter; el manifiesto offline retira ese permiso de la variante de publicación. | El APK físico no acredita por sí mismo los permisos del AAB de Play. | Inspeccionar el manifiesto combinado del AAB offline firmado antes de subirlo. | El inspector del AAB firmado `0.1.4+21` aprobó los ocho controles: paquete, versión, API 28/36, permisos, copia Android desactivada, firma y alineación ELF. La prueba en teléfono de 16 KB sigue pendiente. |
| Preparar datos de tienda | Console no tenía ficha predeterminada; el borrador local de privacidad carecía de responsable y contacto confirmados. | Un AAB con datos inventados o una política de la variante conectada informaría mal a quienes prueben el piloto offline. | Confirmar nombre y correo públicos, publicar una política offline separada y compilar esos valores en el AAB. | El titular confirmó Iv6n y el correo público; la política offline se publicó y abrió sin iniciar sesión en `https://libretapp-mexico.delcarmenmariscos.chatgpt.site/privacidad/offline/`. El AAB firmado incorporó URL y correo; SHA-256 `b82719414d7bd8a00abf92da2613cee8de290b4fc80904b86052a4eaadecf7ce`. Certificado de subida de Console y aceptación física pendientes. |
| Leer privacidad en el piloto offline | La ayuda decía que se borraba una cuenta por SMS y respaldos remotos incluso cuando la variante offline no los ofrece. | Podía confundir sobre qué datos existen y cómo eliminarlos. | Mostrar solo la ruta de Android para borrar datos locales y recordar que los archivos exportados se borran en su destino; conservar el texto de cuenta para la variante conectada. | Prueba de widget con texto al 200 % aprobada; APK actualizado en el OPPO y árbol de accesibilidad confirmó «Borrar datos» sin «SMS». AAB de QA regenerado y verificado. |
| Abrir Cuenta en el piloto offline | La tarjeta de invitado ya decía que los registros se guardan en el dispositivo, pero añadía una frase sobre activar copias en la nube inexistentes en esta variante. | Repetía el estado local y sugería una función inaccesible. | Mostrar la frase de copias automáticas solo cuando está habilitada la nube y no se trata de una demo. | Seis pruebas de navegación y estados de Perfil aprobadas; APK actualizado en el OPPO con SHA-256 `B92562C717EFB45892B404ECF0D088D3EBD44D9F5088BF11418166C5097BFD28`. En Cuenta verificada no aparece el aviso de nube; la variante invitado se comprobó en widget. |
| Crear una copia del espacio personal | Antes de la exportación, Datos y respaldos indicaba que aún no había una copia local. | Sin un archivo verificable no se puede planificar la transición de firma hacia Play. | Exportar un `.libretbackup` únicamente a Descargas del OPPO y comprobarlo allí sin restaurar ni transferir datos personales. | El 03/11 se guardó un archivo de 159,421 bytes; SHA-256 `da301d175b770ad68d0427abe384c87dedbc88f88cca0cee7845d6a695be75ec`. `unzip -tq` en el teléfono no halló errores; el ZIP contiene `manifest.json` de esquema 11 y un adjunto `media/` cuyo contenido coincide con el SHA-256 de su nombre. La app mostró «Respaldo guardado» y Directorio conservó un animal. Restauración en otro teléfono desechable pendiente. |
| Revisar Agenda y respaldo en teléfono | En el OPPO de 360 dp, el formulario mostró Guardar, Agenda mostró Programar actividad y Datos y respaldos mostró exportar e importar. UI Automator no expuso la etiqueta del `EditText` de Título; el árbol semántico de Flutter sí contiene una sola etiqueta «Título *». | La voz real de TalkBack sigue sin comprobarse. | Mantener la etiqueta existente y verificar el anuncio en TalkBack antes de cambiar el widget. | Navegación física sin guardar ni restaurar y prueba semántica de Flutter; TalkBack pendiente. |
| Exportar un respaldo con versión reconocible | La suite encontró que `pubspec.yaml` decía 0.1.4+20 y `BackupEnvelope.currentAppVersion` aún estampaba 0.1.4+15. | Un archivo nuevo informaría una versión de origen incorrecta durante recuperación. | Sincronizar el valor predeterminado con 0.1.4+20 sin alterar el esquema 11. | Prueba `backup_version_test.dart`, recuperación nativa y suite completa en serie: 1,522 aprobadas, 1 omitida. |
| Salir de un formulario con captura | En la misma secuencia de eventos, el botón Atrás podía cerrar antes de que `PopScope` recibiera el cambio del campo. | Pérdida de texto sin preguntar. | Interceptar siempre el intento de salida y comprobar el estado real del formulario antes de cerrar. | Cinco pruebas de `app_form_exit_guard_test.dart` aprobadas, incluidas cancelar y confirmar descarte. |
| Guardar un animal sin arete | El indicador de guardado se activaba antes de responder «Dejar arete pendiente» y mantenía una animación continua. | La confirmación parecía un guardado en curso y las pruebas de interfaz no terminaban. | Activar el estado de guardado después de confirmar; conservar el bloqueo durante la escritura. | Dieciocho pruebas de `quick_register_animal_page_test.dart` aprobadas, incluidos texto 200 %, fallo y reintento. |
| Editar un peso heredado de cero | La prueba intentaba crear un registro nuevo con cero mediante la API que ahora lo rechaza. | No comprobaba la compatibilidad con datos antiguos. | Sembrar el valor histórico directamente en una base desechable y verificar edición sin alterar el peso; exigir peso positivo en altas nuevas. | Prueba Isar enfocada aprobada; sin cambio de esquema. |
| Abrir Lugares vacío | El OPPO mostraba «Todos 0» encima de «Sin ubicaciones». | El filtro no ofrecía ninguna elección y empujaba la ilustración hacia abajo. | Ocultar la fila cuando no existe ninguna ubicación; conservarla para contenido y resultados filtrados. | Prueba enfocada y suite completa aprobadas; APK offline debug código 21 instalado en el OPPO mostró «Sin ubicaciones» y «Crear ubicación» sin «Todos 0». |
| Reabrir el espacio sin conexión | Tras actualizar el OPPO del código 20 al 21 sin borrar datos, Directorio conservó un animal. | Una actualización o reapertura no debe perder la ficha local. | Mantener la actualización en sitio y comprobar lectura tras forzar cierre con Wi-Fi apagado y datos móviles ya apagados. | En Android API 31, el árbol de accesibilidad mostró «1 animal» tras la reapertura sin conexión; Wi-Fi se devolvió a encendido. No se ensayó restauración de datos personales. |

## Orden provisional

1. Completar el primer registro y encontrar la acción principal en Inicio,
   onboarding y Directorio.
2. Editar sin pérdida y recuperar una copia, especialmente tras fallar un
   guardado o reabrir sin conexión.
3. Reducir repeticiones en Agenda, Reportes y Perfil.

Es un orden por riesgo de tarea. La frecuencia de problemas y el orden final
dependen de las cinco observaciones; no se infieren de pruebas internas.

## Recolección pendiente

La revisión Android de esta entrega se limita al OPPO por indicación del
titular. API 28, Android de 16 KB y las restauraciones en un dispositivo de
prueba siguen pendientes; no se atribuyen al teléfono personal. El OPPO
rechazó `settings put system font_scale` por falta de `WRITE_SETTINGS` y
conservó la escala original 1.0; texto ampliado físico y TalkBack requieren
revisión manual del ajuste en el teléfono.

En un espacio de prueba desechable, recorrer ambos sabores Android con Inicio
vacío y con datos: alta, búsqueda, edición, registro, Agenda, Reportes, Perfil,
exportación y restauración. Repetir en 320, 360 y 412 dp, claro/oscuro, texto
normal y 200 %, teclado abierto, sin conexión y fallo de guardado. Revisar
TalkBack y anotar tarea, comportamiento, impacto, cambio y verificación. Las
capturas de revisión son temporales y se eliminan después de anotar resultados.

Observar cinco personas piloto: principalmente trabajadores de rancho e incluir
al menos una persona con uso mixto o mascotas. Pedirles que inicien, registren,
encuentren y editen una ficha, programen trabajo y creen una copia. Registrar
finalización, dudas, desvíos y palabras usadas; ordenar cambios por fallo de
tarea y frecuencia. **Validación con usuarios: pendiente; no se ha reclutado ni
observado a participantes.**

## Verificación ejecutada

- Verificación actual del 3 de noviembre: `flutter test --no-pub
  --concurrency=1` terminó con 1,522 pruebas aprobadas y una omitida.
  `flutter analyze --no-pub --no-fatal-infos` terminó con código 0, sin errores
  ni advertencias; mantiene 354 notas informativas de estilo. La ejecución
  paralela agotó el límite de 30 s de una prueba pesada de DEMO; esa prueba
  aislada pasó en 11 s y la suite completa en serie aprobó.

- La matriz `docs/piloto/directorio-cobertura.csv` contenía 32 rutas de imágenes
  retiradas en 27 filas. Se eliminaron las 32 referencias. Las siete filas con
  revisión reciente enlazan a este registro; las demás indican que el recorrido
  Android actual debe repetirse. Las pruebas automatizadas siguen citadas sin
  presentarlas como observación manual.

- `flutter analyze --no-pub --no-fatal-infos`: terminó sin errores ni avisos
  de análisis; informó 354 notas de estilo en el repositorio.
- 281 pruebas enfocadas de onboarding, Inicio, Agenda, Registro, Reportes,
  Perfil, accesibilidad y vistas previas aprobaron. Otras 20 pruebas de
  Directorio aprobaron; la tarjeta compacta volvió a pasar ocho variantes
  de tamaño y tema. La ficha completa pasó 54 variantes de especie, tamaño,
  tema y texto ampliado. La prueba de Agenda a 360 dp confirmó que «Guardar
  tarea» permanece visible con el teclado abierto y que la validación del
  tipo obligatorio sigue funcionando.
- Los recorridos Android sin conexión y conectado pasaron en el emulador API
  28: alta y edición de ficha, archivo y recuperación de copia nativa. El
  recorrido conectado ejercitó almacenamiento local; no configuró SMS ni una
  cuenta remota. En el APK normal sin conexión, el primer registro siguió
  visible tras forzar cierre y reabrir. El OPPO CPH2123 de 360 dp conservó el
  perfil y su ficha al actualizar de código 19 a 20; se revisaron Inicio,
  búsqueda y ficha en Directorio, Agenda, formulario de tarea, Reportes,
  Perfil y el acceso a respaldos sin alterar los datos personales. Las pruebas
  de widgets cubren 320, 360 y 412 dp, tema claro y oscuro y texto ampliado;
  la inspección manual con TalkBack y cinco participantes queda abierta.
- APK previo `offlineDebug` `0.1.4+20` instalado el 3 de noviembre en el OPPO
  con `adb install -r` y datos conservados (SHA-256:
  `A90148C49A55F21B45B1264497505A86990E81F4DA6AACE67EC18DD864B4285B`).
  Se abrió Agenda con teclado, se tocó Guardar y aparecieron errores de campos
  obligatorios sin crear una tarea. Reportes ocultó el contador vacío de partos;
  Perfil mantuvo el estado y los accesos de respaldo. Las capturas temporales
  del equipo y del teléfono se eliminaron tras la revisión.
- El APK `offlineDebug` actualizado con la corrección de versión del respaldo
  (SHA-256 `7DF8F51806811CCCC3D9C4FBAA2D9CFCA9E05C055585633260B16CEB5441ED64`)
  se instaló con `adb install -r` el 3 de noviembre a las 10:14, conservando
  versión 0.1.4+20 y certificado debug. La app abrió y Directorio siguió
  mostrando un animal y su tarjeta; no se leyó ni alteró la ficha personal.
  `font_scale` permaneció en 1.0.
- El APK `offlineDebug` con la barra transparente y las ilustraciones
  restauradas se instaló con `adb install -r` en el OPPO, sin desinstalar ni
  restaurar datos personales: `0.1.4+20`, SHA-256
  `295EEFE568A96DE6650D0A4927349DF30FDF167213F5F0CB5AA098D26E92C472`.
  Lotes y Agenda se revisaron en el equipo; sus capturas temporales se borraron.
  `flutter analyze --no-pub --no-fatal-infos` terminó sin errores ni advertencias
  (354 notas de estilo existentes) y 53 pruebas enfocadas aprobaron.
- Se compiló un primer AAB offline de **QA**, código 21 y certificado debug
  `f7fb3f8f21b49bb4ebdc9c7fd08669817617ac47bf02978fa2fe21f6352b02f2`,
  SHA-256 `4AE398ED266072731EC86AA930E65536F824B1645D7EF19F5514B4F5240C554E`.
  El manifiesto final declara `app.libret`, mínimo 28, objetivo 36, copia de
  Android desactivada y ningún permiso de Internet, GPS o Bluetooth.
  `jarsigner` verificó la firma y `llvm-readelf` comprobó las 14 bibliotecas
  de 64 bits sin segmentos por debajo de 16 KB. Se hizo inspección manual
  porque Python no está disponible en esta sesión; este archivo con firma de
  prueba no es un AAB de subida ni tiene constancia de aceptación.
- Tras restaurar la ilustración de Agenda y retirar las capas opacas de la
  barra común, la suite Flutter completa en serie terminó con **1,522 pruebas
  aprobadas y 1 omitida**. El análisis final no tuvo errores ni advertencias;
  `git diff --check` no halló errores de espacios. El barrido de nombres de
  capturas en el proyecto no encontró archivos; el único enlace de imagen en
  Markdown de diseño apunta a un estudio de iconos conservado.
- La corrección posterior del texto de privacidad se instaló de nuevo con
  `adb install -r` en el OPPO: APK SHA-256
  `F11FA4036F154629B4B6A8A004EACAA716AE2E6E8D9CEDCE601ED233F4F71B68`.
  La ficha única seguía visible; en Ayuda se anunció «Borrar datos» y no «SMS».
  El equipo volvió a Directorio y las capturas temporales se eliminaron.
- Después de ese último cambio, la suite completa volvió a terminar con
  **1,522 pruebas aprobadas y 1 omitida**. `flutter analyze --no-pub
  --no-fatal-infos` informó 354 notas de estilo y cero errores o advertencias.
  Ese AAB de QA quedó obsoleto tras el ajuste final de Cuenta.
- Después de ese ajuste, `flutter analyze --no-pub --no-fatal-infos` volvió a
  terminar con cero errores y advertencias (354 notas de estilo existentes), y
  la suite completa terminó con **1,522 pruebas aprobadas y 1 omitida**. El
  nuevo APK offline debug se instaló en el OPPO sin borrar datos; SHA-256
  `B92562C717EFB45892B404ECF0D088D3EBD44D9F5088BF11418166C5097BFD28`.
  El AAB offline de **QA** actualizado está fuera del proyecto en
  `libret-offline-qa-current2/LibretApp-0.1.4+21-offline-qa.aab`, SHA-256
  `95DCAE2CD5E182A992BAD94569A77034B086574AB3F527B192596FF1E4EFCA5D`.
  `jarsigner` y `keytool` confirmaron el certificado debug; el manifiesto
  declara `app.libret`, código 21, mínimo 28, objetivo 36, sin Internet, GPS
  ni Bluetooth, y sin copia de Android. Los 14 ELF de 64 bits tienen segmentos
  de carga alineados a 16 KB o más. `qa-inspection.json` marca
  `readyForStore: false`: aún faltan datos reales del titular, certificado de
  subida confirmado, restauración física separada y revisión antes de Play.
