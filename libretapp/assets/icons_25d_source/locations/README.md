# Maestros 2.5D de Ubicaciones

Esta carpeta conserva los 53 maestros PNG de Ubicaciones generados a partir
de `docs/design/icons-25d-v2/modelo-25d-v2.png`.

Los archivos de producción mantienen los nombres `location_*.webp` en
`assets/images/`. Los PNG maestros no se incluyen en el paquete de Flutter.

`PROMPTS.md` conserva la dirección visual y la semántica de cada recurso. La
exportación se ejecuta con:

```text
python tool/export_generated_25d_icons.py --scope locations
```

Alcance: 46 tipos concretos de `LocationType` y 7 recursos de categoría. Los
13 animales y los otros 64 iconos 2.5D quedan fuera de esta fase.
