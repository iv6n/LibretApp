/// features › ubicaciones › domain › enums › location_category — broad operational category of a location.
library;

/// Broad operational category of a Location.
///
/// Used for filtering, UI grouping, analytics, and GIS layer management.
/// Each [LocationType] belongs to exactly one [LocationCategory].
enum LocationCategory {
  /// Macro-property level: ranches, farms, ejidos, haciendas.
  macro,

  /// Cultivated land: fields, milpas, orchards, greenhouses.
  agricultural,

  /// Animal housing and grazing: pastures, corrals, barns, stables.
  livestock,

  /// Animal handling infrastructure: chutes, loading areas, quarantine.
  handling,

  /// Natural areas: forest, scrubland, lagoons, rivers, protected zones.
  natural,

  /// Built infrastructure: warehouses, workshops, offices, roads.
  infrastructure,

  /// Water resources: wells, dams, springs, ponds, troughs.
  water,
}
