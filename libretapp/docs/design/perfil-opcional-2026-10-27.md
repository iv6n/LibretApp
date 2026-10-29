# Perfil opcional antes de Inicio

Implementación del plan aprobado el 27 de octubre de 2026.

## Recorrido

1. Bienvenida y selección de experiencia.
2. Vista previa y selección de acceso, con las demos independientes existentes.
3. **Un toque personal**, identificado como **Opcional**, para espacios reales con perfil vacío que aún no hayan resuelto este paso.
4. Inicio, al guardar cualquier combinación de campos o pulsar **Ahora no**.

El formulario tiene contenido desplazable, acciones inferiores fuera del desplazamiento, etiquetas de campos, tipos de teclado y autofill apropiados. Reutiliza la marca, los colores del tema y una ilustración existente. Los datos del rancho solo aparecen en Ganado y campo dentro de un desplegable inicialmente cerrado.

## Persistencia e integración

- Ruta independiente `/bienvenida/perfil`, integrada mediante el guard de navegación a Inicio tanto después del acceso como al arrancar un espacio activo.
- Servicio registrado por espacio en las dependencias nativas y web, con resolución en preferencias aisladas y en memoria para evitar bucles si falla la escritura de la marca.
- Guardado mediante los modelos y repositorios existentes. Mantiene identificador, región, configuración productiva y campos ganaderos ocultos en Mascotas y plantas.
- No persiste borradores ni envía los datos a servicios externos. Las demos evitan esta invitación y no escriben perfiles reales.
- Atrás cierra primero el teclado y después equivale a omitir. Los envíos repetidos quedan bloqueados mientras hay una operación pendiente.
- Nombre y apellido dejaron de ser obligatorios en el editor posterior. La ausencia de UPP no genera una indicación de perfil incompleto.

## Cobertura preparada y estado de validación

Se añadieron pruebas de servicio, formulario y editor para guardado vacío o parcial, UPP con ceros iniciales, correo opcional, perfiles existentes, demos, resolución por espacio, reapertura, errores, doble pulsación, teclado, Atrás, texto al 200 %, temas y objetivos táctiles. La prueba de cambio de espacio también comprueba la invitación después de preparar una cuenta.

Se aprobaron 125 pruebas de regresión de bienvenida, perfil, espacios y experiencias domésticas, además de la generación de seis capturas del formulario Flutter en tamaño de pantalla OPPO (ambas experiencias y temas, con rancho desplegado en Ganado y campo). El análisis estático de los archivos del cambio quedó sin incidencias. Se comprobaron también las áreas táctiles y las etiquetas con las guías automatizadas de accesibilidad; esto no sustituye una revisión manual con TalkBack.

Las capturas se encuentran en `artifacts/onboarding-profile/`. El resultado de regresión está en `regression-tests.jsonl`. La revisión automática de aprobación inicialmente agotó su límite de uso y después permitió continuar las herramientas; no queda bloqueada la validación automatizada.

Se compiló el APK `standard release` para ARM64 con la configuración telefónica existente. El OPPO CPH2123 volvió a estar disponible y recibió la actualización con `adb install -r`, sin desinstalar ni borrar sus registros. El APK definitivo es `artifacts/onboarding-profile/LibretApp-perfil-opcional-2026-10-27.apk`.

En el OPPO se revisaron ambos formularios, el rancho desplegado y plegado, el teclado con las acciones visibles, Atrás cerrando el teclado, la reapertura de un paso pendiente y la llegada a Inicio mediante **Ahora no**. Al reiniciar después de omitir no se repitió la invitación. Ambas demos abrieron directamente con sus datos y navegación, y al salir se recuperó el espacio real vacío. No se guardaron datos personales ficticios en el espacio real ni se solicitaron SMS durante esta revisión. Las capturas físicas están en `artifacts/onboarding-profile/oppo/`.

Las pruebas de errores de almacenamiento, las combinaciones de campos y el editor sin nombre ni apellidos son automatizadas. Los temas claro y oscuro y el texto al 200 % se comprobaron con widgets Flutter. La lectura manual con TalkBack sigue sin comprobarse.
