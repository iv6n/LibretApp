# Location Image Assets

This app already has animal PNGs in `assets/images/` using a soft, rounded,
transparent-background ranch illustration style. Location images should match
that language: centered square PNGs, warm earthy colors, subtle 2.5D shading,
simple silhouettes, no text, no people, no animals, no hard outlines.

## Existing Animal Style

- Format: PNG, square composition, transparent background.
- Look: soft vector-like raster illustration with rounded simplified shapes.
- Palette: terracotta browns, cream highlights, muted greens, hay golds.
- Detail level: readable at card/avatar size, minimal texture, no labels.

## Generated Exploration

Reference sheet saved at:

`assets/images/location_style_exploration.png`

It explores seven representative locations: ranch, pasture, corral, field,
forest, warehouse, and pond. Treat it as style direction, not production input.
Production assets should be individual transparent PNG files.

## Implemented Assets

The current production pass uses a hybrid model: common `LocationType` values
have specific artwork, and every other type falls back to its category anchor in
`LocationTypeAvatar`.

Specific type assets:

- `assets/images/location_warehouse.png`
- `assets/images/location_monte.png`
- `assets/images/location_ejido.png`
- `assets/images/location_corral.png`
- `assets/images/location_spring.png`
- `assets/images/location_well.png`
- `assets/images/location_pond.png`
- `assets/images/location_pasture.png`
- `assets/images/location_field.png`
- `assets/images/location_barn.png`
- `assets/images/location_house.png`
- `assets/images/location_road.png`
- `assets/images/location_gate.png`
- `assets/images/location_water_tank.png`

Category fallback assets:

- `assets/images/location_macro.png`
- `assets/images/location_livestock.png`
- `assets/images/location_handling.png`
- `assets/images/location_agricultural.png`
- `assets/images/location_natural.png`
- `assets/images/location_infrastructure.png`
- `assets/images/location_water.png`

Source sheet for the specific assets:

`assets/images/location_type_sheet.png`

## Per-Type Naming Convention

Use one image per `LocationType`:

`assets/images/location_<location_type>.png`

Examples:

- `location_ranch.png`
- `location_quarantine_area.png`
- `location_water_tank.png`

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
Style/medium: soft 2.5D vector-style raster illustration matching the existing animal PNG assets: rounded simplified shapes, warm agricultural palette, subtle gradients, gentle highlights, no hard outlines, no photorealism.
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
