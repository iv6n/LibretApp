# Task Image Assets

Task illustrations use the same soft 2.5D raster language as the location
assets: centered square WEBPs, warm agricultural colors, simple silhouettes,
subtle highlights, no text, people, animals or watermarks, and real RGBA
transparency.

## Tanda 6 — Tareas ganaderas específicas

- `assets/images/task_milking.webp`
- `assets/images/task_tick_bath.webp`
- `assets/images/task_vitamins.webp`
- `assets/images/task_hoof_check.webp`
- `assets/images/task_reproductive_check.webp`
- `assets/images/task_fertilization.webp`
- `assets/images/task_fumigation.webp`
- `assets/images/task_harvest.webp`
- `assets/images/task_deworming.webp`
- `assets/images/task_annual_vaccination.webp`

All task assets are compressed 256×256 WEBP files with RGBA transparency.
Agenda maps deworming and vaccination tasks to their specific assets and keeps
the Material icon as a runtime fallback when an asset is unavailable.

## Naming convention

Use one asset per task:

`assets/images/task_<task_type>.webp`
