# Crop Image Assets

Crop illustrations use the same soft 2.5D raster language as the location,
task, status, health, inventory and record assets: centered square WEBPs, warm
agricultural colors, simple silhouettes, no text or watermarks, and real RGBA
transparency.

## Tanda 12 - Crop growth stages

- `assets/images/crop_field.webp`
- `assets/images/crop_germinating.webp`
- `assets/images/crop_vegetative.webp`
- `assets/images/crop_flowering.webp`
- `assets/images/crop_fruiting.webp`
- `assets/images/crop_ready_to_harvest.webp`
- `assets/images/crop_harvested.webp`
- `assets/images/crop_failed.webp`

All Tanda 12 assets are compressed 256×256 WEBPs with real RGBA transparency.

## Integración

Las tarjetas de cultivos seleccionan automáticamente el asset según la etapa
de crecimiento. Los estados `harvested` y `failed` tienen prioridad sobre la
etapa registrada para mostrar `crop_harvested.webp` o `crop_failed.webp`.
Si un archivo no está disponible, la tarjeta conserva el icono Material de
respaldo.

## Naming convention

`assets/images/crop_<stage>.webp`
