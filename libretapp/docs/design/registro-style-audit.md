# Auditoría de formato y estilo de registros

Fecha: 15 de octubre de 2026.

## Criterio aplicado

Los registros comparten una estructura visual y conservan su identidad mediante
nombre, icono o ilustración, descripción breve y acento de color. La identificación
no depende únicamente del color.

- Encabezado: `AppRecordHeader`, con tipografía del tema y una insignia de 48 px.
- Identidad: `RecordFormStyle` centraliza los recursos y colores del menú y los
  formularios. Destete conserva un icono propio como alternativa a una ilustración.
- Contenido: `AppFormBody`, con márgenes de 16 px, ancho máximo de lectura de
  720 px, área segura y desplazamiento al abrir el teclado.
- Acciones: `AppFormActions`, con Guardar y Cancelar. Se apilan en áreas menores
  de 360 px o con texto ampliado; durante el guardado quedan deshabilitadas.
- Los campos de `AppFormScaffold` no reciben interacción durante el guardado.
- Los flujos con pasos o captura continua conservan sus controles particulares.

## Alcance revisado y corregido

| Grupo | Registros |
| --- | --- |
| Altas | Animal completo y rápido, lote, ubicación y cultivo |
| Animales | Peso, sanitario, costo, movimiento, producción y comercial, desde el menú y el perfil |
| Ciclo reproductivo | Servicio, diagnóstico, parición y destete |
| Manejo colectivo | Selección de animales y aplicación de tratamientos, incluida la acción desde el perfil |
| Producción de leche | Ordeña individual y por lote |
| Cultivos | Alta o edición, cosecha, riego, salud y tareas |
| Finanzas | Ingreso y gasto general |
| Identificación electrónica | Encabezado y disposición de RFID |

## Hallazgos resueltos

| Hallazgo | Corrección |
| --- | --- |
| Encabezados e identidades definidos de distintas maneras | Catálogo común, mismo encabezado y recursos existentes |
| Formularios particulares sin límite de ancho | Contenido centrado y ancho máximo común |
| Cosecha, riego, salud y tareas de cultivo sin desplazamiento | Área desplazable para acceder a campos y acciones con teclado o texto grande |
| Acciones con distintas alturas y disposiciones | Componentes compartidos y adaptación al ancho disponible |
| Desbordamiento de «Guardar diagnóstico» junto al indicador de carga | Texto flexible en el botón compartido |
| Cancelar con poco contraste en modo oscuro | Texto y borde claros, usando el color de contenido del tema |
| Selección por lote con controles horizontales y altura rígida | Controles que se ajustan y lista con desplazamiento conjunto y construcción por demanda |
| Títulos del menú sin acentos | Corrección de Menú, Ubicación, Parición, Producción y Reproducción |
| Destete con campos sin separación y sin identidad común | Encabezado, icono, espacios y acción de cancelar |

## Verificación

Resultado: 105 pruebas distintas verificadas en las tandas de validación, incluidas
las dos vistas previas.
El análisis estático final de los componentes compartidos, la selección por lote,
el catálogo de identidad y sus pruebas terminó sin observaciones.

Se ejecutan pruebas de validación y guardado, reproducción, altas, ubicación,
cultivos, ordeña y componentes compartidos. La cobertura de disposición incluye
320 px, texto al doble de tamaño, teclado abierto, temas claro y oscuro, y límite
de ancho en escritorio.

`test/features/registro/registro_form_layout_test.dart` comprueba los cinco
formularios de cultivo con teclado y texto grande, el bloqueo durante el guardado
y el ancho de lectura. La prueba de registros también cubre la selección por lote
en esas condiciones y verifica que el menú y los formularios compartan identidad.

Para reproducir la vista comparativa de componentes comunes:

```powershell
flutter test tool/preview_record_styles_test.dart
```

Genera `build/record_style_audit/light.png` y `dark.png`, revisadas visualmente.
Estas capturas muestran la estructura compartida con campos de ejemplo; las
pruebas de flujo utilizan los formularios reales. Las capturas no sustituyen una
comprobación de hardware RFID ni una revisión en un dispositivo físico.
