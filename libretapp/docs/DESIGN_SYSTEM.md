# Sistema visual de LibretApp

La misma identidad se aplica a Onboarding, Inicio, Directorio, Registro, Agenda,
Ubicaciones y cultivos, Finanzas, Reportes, Perfil, Biblioteca, Exportar y demo.
Los flujos y datos de cada módulo conservan su comportamiento.

## Color

Los roles viven en [`lib/theme/app_theme.dart`](../lib/theme/app_theme.dart).
En widgets se consulta `Theme.of(context).colorScheme`; los valores fijos solo
se usan al definir el tema. Los colores de especie, salud y riesgo conservan
su significado y siempre llevan texto o icono además del color.

| Rol | Claro | Oscuro | Uso |
|---|---|---|---|
| Acción principal | `#2F5D50`, texto blanco | `#9DE5CB`, texto `#0C3027` | `ColorScheme.primary/onPrimary`, CTA, FAB, selección y foco |
| Fondo | `#FFFDF8` | `#0F1B1F` | Página |
| Superficie | `#FAF6EE` y crema `#F6F1E8` | `#0F1B1F` y `#15262C` | Tarjetas, controles y paneles |
| Salvia | `#DDECE3`, texto `#18362D` | `#28473D`, texto `#DDECE3` | Paneles destacados y selecciones |
| Café cuero | `#7B4B2A` | `#E8BA94` | Detalles y categorías de tierra; no CTA principal |
| Información | `#366079` | `#9CCBE5` | Chip o aviso informativo |
| Éxito | `#136F35` | `#9ADEA8` | Estado favorable |
| Atención | `#8D5D00` | `#F3C677` | Advertencia |
| Error | `#B91C1C` | `#FFB4AB` | Error y acción destructiva |

Los tonos de estado se consultan mediante `AppStatusTheme`. Sus chips usan un
fondo translúcido y texto del tono correspondiente. En superficies diferentes,
comprobar contraste de texto y borde antes de usar el color.

## Medidas y tipografía

| Token | Valores | Uso |
|---|---|---|
| `AppSpacing` | 4, 8, 12, 16, 20, 24, 32 dp | Separaciones y márgenes |
| `AppRadii` | 8, 12, 16, 24, 999 dp | 12 campos; 16 tarjetas y botones; 24 paneles ilustrados; píldora estados |
| `AppControlMetrics` | 48 dp normal; 40 dp compacto | Interacción: objetivo táctil de 48 dp para acciones |
| `AppTextStyles` | `titleLg`, `titleMd`, `body`, `bodySmall`, `label` | Título de página, sección/tarjeta, cuerpo, dato secundario y etiqueta |

Roboto es la fuente funcional. Se toma `Theme.of(context).textTheme` en vez
de fijar tamaños dentro de cada pantalla. El texto puede llegar al 200 %:
permitir varias líneas y desplazamiento, sin truncar datos o acciones.

## Componentes

Los componentes compartidos están en `lib/core/widgets/` y se exportan desde
`widgets.dart`.

| Necesidad | Componente |
|---|---|
| Acción principal, secundaria o terciaria | `AppButton` |
| Acción de icono | `AppIconButton`, con descripción accesible |
| Tarjeta genérica | `AppCard` |
| Estado, filtro o selección | `AppChip` |
| Lista sin datos | `AppEmptyState` |
| Carga de página o sección | `AppLoadingIndicator` |
| Búsqueda | `AppSearchBar` |
| Texto, selección y sección de formulario | `AppTextField`, `AppSelectField`, `AppFormSection` |
| Encabezado | `AppPageHeader` |

Usar `AppButton(primary)` o `FilledButton` para la acción principal de una
superficie. Los botones Flutter y el FAB toman `ColorScheme.primary/onPrimary`.
Las acciones secundarias usan contorno o texto; las destructivas, el rol error.
Cuando una tarjeta especializada requiere otro contenido, conserva su estructura
pero adopta color, borde, espacio y estados del tema. Extender un componente
compartido solo cuando aparece una variante real reutilizable.

## Iconos, imágenes y lenguaje

- Usar un tamaño constante por tipo de acción y un objetivo táctil de 48 dp.
  Cada icono interactivo necesita etiqueta semántica o tooltip.
- El catálogo de vaca, canino, felino, cultivos, ubicaciones y actividades es
  la referencia visual: ilustración 2.5D amable, fondo transparente, figura
  completa, encuadre centrado y nitidez suficiente para pantallas densas.
- La bienvenida usa `onboarding_welcome_group.png`, una escena conjunta de
  vaca, perro, gato y planta. La vista previa usa `vaca.webp` y
  `onboarding_monstera_illustration.png`. Las tarjetas y textos son widgets,
  no parte de una imagen plana. Las fotos subidas por usuarios son contenido.
- Usar términos apropiados para mascotas, ganado y cultivos. En mascotas,
  mostrar la etiqueta «Mascota» y evitar vocabulario de etapas ganaderas.

## Estados y accesibilidad

Revisar cada vista con contenido, vacío, carga, error y sin conexión en temas
claro y oscuro. Mantener el foco visible, las acciones por encima del teclado,
respeto a movimiento reducido y acceso con lector de pantalla. El estado o la
selección se explica mediante texto o icono, nunca solo con color. Las vistas
desplazables deben permitir llegar a todas las acciones en 320 × 568 con texto
al 200 %.
