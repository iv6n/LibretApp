# Fuentes raster 2.5D

Esta carpeta conserva las imágenes PNG maestras generadas individualmente a
partir del modelo visual de `docs/design/icons-25d-v2/modelo-25d-v2.png`.

Los archivos de ejecución de la aplicación se exportan como WEBP de 256×256 en
`assets/images/`, manteniendo los nombres existentes. Los PNG de esta carpeta
no se incluyen en el paquete de Flutter.

Alcance: 64 iconos de Cultivos, Salud, Inventario y Finanzas, Registro,
Estados y Tareas. Los animales y los recursos `location_*` están excluidos.

La colección se creó con la herramienta integrada de generación de imágenes,
usando `docs/design/icons-25d-v2/modelo-25d-v2.png` como referencia de estilo.
El conjunto de instrucciones y conceptos se conserva en `PROMPTS.md`.

Para normalizar los PNG, retirar cualquier cuadrícula de transparencia
renderizada y exportar los WEBP finales:

```text
python tool/export_generated_25d_icons.py
```

El proceso escribe de forma atómica, centra cada silueta dentro de un área de
202×202 px y garantiza un lienzo WEBP transparente de 256×256.
