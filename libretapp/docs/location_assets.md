# Location Image Assets

This app already has animal WEBP assets in `assets/images/` using a soft, rounded,
transparent-background ranch illustration style. Location images should match
that language: centered square WEBPs, warm earthy colors, subtle 2.5D shading,
simple silhouettes, no text, no people, no animals, no hard outlines.

## Existing Animal Style

- Format: compressed WEBP, 256×256 square composition, transparent RGBA background.
- Look: soft vector-like raster illustration with rounded simplified shapes.
- Palette: terracotta browns, cream highlights, muted greens, hay golds.
- Detail level: readable at card/avatar size, minimal texture, no labels.

## Generated Exploration

Reference sheet saved at:

`docs/assets/location_style_exploration.png`

It explores seven representative locations: ranch, pasture, corral, field,
forest, warehouse, and pond. Treat it as style direction, not production input.
Production assets should be individual 256×256 WEBP files with real RGBA
transparency.

## Implemented Assets

The current production pass uses a hybrid model: common `LocationType` values
have specific artwork, and every other type falls back to its category anchor in
`LocationTypeAvatar`.

Specific type assets:

- `assets/images/location_ranch.webp`
- `assets/images/location_farm.webp`
- `assets/images/location_finca.webp`
- `assets/images/location_hacienda.webp`
- `assets/images/location_plantation.webp`
- `assets/images/location_warehouse.webp`
- `assets/images/location_monte.webp`
- `assets/images/location_ejido.webp`
- `assets/images/location_corral.webp`
- `assets/images/location_feedlot.webp`
- `assets/images/location_stable.webp`
- `assets/images/location_pen.webp`
- `assets/images/location_chute.webp`
- `assets/images/location_quarantine_area.webp`
- `assets/images/location_loading_area.webp`
- `assets/images/location_weighing_area.webp`
- `assets/images/location_spring.webp`
- `assets/images/location_well.webp`
- `assets/images/location_pond.webp`
- `assets/images/location_pasture.webp`
- `assets/images/location_field.webp`
- `assets/images/location_barn.webp`
- `assets/images/location_house.webp`
- `assets/images/location_property.webp`
- `assets/images/location_homestead.webp`
- `assets/images/location_plot.webp`
- `assets/images/location_milpa.webp`
- `assets/images/location_orchard.webp`
- `assets/images/location_greenhouse.webp`
- `assets/images/location_nursery.webp`
- `assets/images/location_garden.webp`
- `assets/images/location_forest.webp`
- `assets/images/location_lagoon.webp`
- `assets/images/location_river.webp`
- `assets/images/location_wetland.webp`
- `assets/images/location_protected_area.webp`
- `assets/images/location_aguada.webp` (used by the dedicated `aguada` type)
- `assets/images/location_workshop.webp`
- `assets/images/location_office.webp`
- `assets/images/location_dam.webp`
- `assets/images/location_trough.webp`
- `assets/images/location_canal.webp`
- `assets/images/location_reservoir.webp`
- `assets/images/location_road.webp`
- `assets/images/location_gate.webp`
- `assets/images/location_water_tank.webp`

Category fallback assets:

- `assets/images/location_macro.webp`
- `assets/images/location_livestock.webp`
- `assets/images/location_handling.webp`
- `assets/images/location_agricultural.webp`
- `assets/images/location_natural.webp`
- `assets/images/location_infrastructure.webp`
- `assets/images/location_water.webp`

Source sheet for the specific assets:

`docs/assets/location_type_sheet.png`

## Per-Type Naming Convention

Use one image per `LocationType`:

`assets/images/location_<location_type>.webp`

Examples:

- `location_ranch.webp`
- `location_quarantine_area.webp`
- `location_water_tank.webp`

## Available Location Types

### Macro Property

- ranch
- farm
- finca
- hacienda
- plantation
- ejido
- property
- homestead

### Livestock

- pasture
- corral
- feedlot
- barn
- stable
- pen

### Handling

- chute
- quarantineArea
- loadingArea
- weighingArea

### Agricultural

- field
- plot
- milpa
- orchard
- greenhouse
- nursery
- garden

### Natural

- monte
- forest
- lagoon
- river
- wetland
- protectedArea

### Infrastructure

- warehouse
- workshop
- office
- house
- road
- waterTank
- gate

### Water

- well
- dam
- spring
- pond
- aguada
- trough
- canal
- reservoir

## Base Prompt

Use this as the shared prompt for each individual asset:

```text
Use case: stylized-concept
Asset type: Flutter mobile app location icon
Primary request: create one centered ranch-management location icon for <LOCATION_LABEL>.
Subject: <LOCATION_DESCRIPTION>.
Style/medium: soft 2.5D vector-style raster illustration matching the existing animal WEBP assets: rounded simplified shapes, warm agricultural palette, subtle gradients, gentle highlights, no hard outlines, no photorealism.
Composition/framing: single isolated subject centered on a square canvas, generous padding, readable at small mobile card/avatar size.
Lighting/mood: soft diffuse app-icon lighting, friendly practical ranch management tone.
Color palette: terracotta browns, pasture greens, hay golds, muted sky blue, cream highlights.
Constraints: transparent background or flat removable chroma-key background, no text, no labels, no logos, no watermarks, no people, no animals, no heavy shadows.
Avoid: photo realism, complex scenery, tiny details, black outlines, decorative frames.
```

For the built-in image tool, generate on a flat chroma-key background first if
true transparency is not directly available, then remove the background locally.

## Future Batch Recommendation

Generate the remaining long-tail `LocationType` values only when the UI needs
more visual differentiation than the category fallback provides.
