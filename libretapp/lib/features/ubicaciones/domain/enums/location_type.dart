/// features › ubicaciones › domain › enums › location_type — enum for the specific type of a location.
///
/// ALL values are English identifiers. Spanish display names live in
/// frontend localization (ARB files) only.
///
/// Migration note: Isar stores these as the enum `.name` string.
/// Old Spanish values (rancho, potrero, etc.) were migrated to English
/// by [LocationEnumMigrationService] on first launch after this change.
library;

import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MACRO PROPERTY
// ─────────────────────────────────────────────────────────────────────────────
// LIVESTOCK
// ─────────────────────────────────────────────────────────────────────────────
// HANDLING
// ─────────────────────────────────────────────────────────────────────────────
// AGRICULTURAL
// ─────────────────────────────────────────────────────────────────────────────
// NATURAL
// ─────────────────────────────────────────────────────────────────────────────
// INFRASTRUCTURE
// ─────────────────────────────────────────────────────────────────────────────
// WATER
// ─────────────────────────────────────────────────────────────────────────────

enum LocationType {
  // ── Macro property ──────────────────────────────────────────────────────
  ranch,
  farm,
  finca,
  hacienda,
  plantation,
  ejido,
  property,
  homestead,

  // ── Livestock ───────────────────────────────────────────────────────────
  pasture,
  corral,
  feedlot,
  barn,
  stable,
  pen,

  // ── Handling ────────────────────────────────────────────────────────────
  chute,
  quarantineArea,
  loadingArea,
  weighingArea,

  // ── Agricultural ────────────────────────────────────────────────────────
  field,
  plot,
  milpa,
  orchard,
  greenhouse,
  nursery,
  garden,

  // ── Natural ─────────────────────────────────────────────────────────────
  /// Scrubland / brushland. Retained as "monte" because it is a recognised
  /// rural-operations management unit in Mexico and Latin America.
  monte,
  forest,
  lagoon,
  river,
  wetland,
  protectedArea,

  // ── Infrastructure ──────────────────────────────────────────────────────
  warehouse,
  workshop,
  office,
  house,
  road,
  waterTank,
  gate,

  // ── Water ───────────────────────────────────────────────────────────────
  well,
  dam,
  spring,
  pond,
  trough,
  canal,
  reservoir,
}

extension LocationTypeX on LocationType {
  /// Fallback display label (English). Production UI should use ARB keys.
  String get label {
    switch (this) {
      case LocationType.ranch:
        return 'Ranch';
      case LocationType.farm:
        return 'Farm';
      case LocationType.finca:
        return 'Finca';
      case LocationType.hacienda:
        return 'Hacienda';
      case LocationType.plantation:
        return 'Plantation';
      case LocationType.ejido:
        return 'Ejido';
      case LocationType.property:
        return 'Property';
      case LocationType.homestead:
        return 'Homestead';
      case LocationType.pasture:
        return 'Pasture';
      case LocationType.corral:
        return 'Corral';
      case LocationType.feedlot:
        return 'Feedlot';
      case LocationType.barn:
        return 'Barn';
      case LocationType.stable:
        return 'Stable';
      case LocationType.pen:
        return 'Pen';
      case LocationType.chute:
        return 'Chute';
      case LocationType.quarantineArea:
        return 'Quarantine Area';
      case LocationType.loadingArea:
        return 'Loading Area';
      case LocationType.weighingArea:
        return 'Weighing Area';
      case LocationType.field:
        return 'Field';
      case LocationType.plot:
        return 'Plot';
      case LocationType.milpa:
        return 'Milpa';
      case LocationType.orchard:
        return 'Orchard';
      case LocationType.greenhouse:
        return 'Greenhouse';
      case LocationType.nursery:
        return 'Nursery';
      case LocationType.garden:
        return 'Garden';
      case LocationType.monte:
        return 'Monte';
      case LocationType.forest:
        return 'Forest';
      case LocationType.lagoon:
        return 'Lagoon';
      case LocationType.river:
        return 'River';
      case LocationType.wetland:
        return 'Wetland';
      case LocationType.protectedArea:
        return 'Protected Area';
      case LocationType.warehouse:
        return 'Warehouse';
      case LocationType.workshop:
        return 'Workshop';
      case LocationType.office:
        return 'Office';
      case LocationType.house:
        return 'House';
      case LocationType.road:
        return 'Road';
      case LocationType.waterTank:
        return 'Water Tank';
      case LocationType.gate:
        return 'Gate';
      case LocationType.well:
        return 'Well';
      case LocationType.dam:
        return 'Dam';
      case LocationType.spring:
        return 'Spring';
      case LocationType.pond:
        return 'Pond';
      case LocationType.trough:
        return 'Trough';
      case LocationType.canal:
        return 'Canal';
      case LocationType.reservoir:
        return 'Reservoir';
    }
  }

  /// Operational category this type belongs to.
  LocationCategory get category {
    switch (this) {
      case LocationType.ranch:
      case LocationType.farm:
      case LocationType.finca:
      case LocationType.hacienda:
      case LocationType.plantation:
      case LocationType.ejido:
      case LocationType.property:
      case LocationType.homestead:
        return LocationCategory.macro;
      case LocationType.pasture:
      case LocationType.corral:
      case LocationType.feedlot:
      case LocationType.barn:
      case LocationType.stable:
      case LocationType.pen:
        return LocationCategory.livestock;
      case LocationType.chute:
      case LocationType.quarantineArea:
      case LocationType.loadingArea:
      case LocationType.weighingArea:
        return LocationCategory.handling;
      case LocationType.field:
      case LocationType.plot:
      case LocationType.milpa:
      case LocationType.orchard:
      case LocationType.greenhouse:
      case LocationType.nursery:
      case LocationType.garden:
        return LocationCategory.agricultural;
      case LocationType.monte:
      case LocationType.forest:
      case LocationType.lagoon:
      case LocationType.river:
      case LocationType.wetland:
      case LocationType.protectedArea:
        return LocationCategory.natural;
      case LocationType.warehouse:
      case LocationType.workshop:
      case LocationType.office:
      case LocationType.house:
      case LocationType.road:
      case LocationType.waterTank:
      case LocationType.gate:
        return LocationCategory.infrastructure;
      case LocationType.well:
      case LocationType.dam:
      case LocationType.spring:
      case LocationType.pond:
      case LocationType.trough:
      case LocationType.canal:
      case LocationType.reservoir:
        return LocationCategory.water;
    }
  }

  /// Whether this type can act as a root/top-level location.
  bool get isRootType => category == LocationCategory.macro;

  /// Macro types that may also nest under specific parents (e.g. ejido under communal monte).
  bool get canNestAsSubLocation => this == LocationType.ejido;

  /// Whether animals can be assigned to this location type.
  bool get supportsAnimals => const {
    LocationType.pasture,
    LocationType.corral,
    LocationType.pen,
    LocationType.feedlot,
    LocationType.barn,
    LocationType.stable,
    LocationType.monte,
    LocationType.quarantineArea,
  }.contains(this);

  /// Whether inventory items can be stored at this location type.
  bool get supportsInventory => const {
    LocationType.warehouse,
    LocationType.house,
    LocationType.barn,
    LocationType.corral,
    LocationType.stable,
    LocationType.workshop,
  }.contains(this);

  /// Whether crop records can be attached to this location type.
  bool get supportsCrops => const {
    LocationType.field,
    LocationType.plot,
    LocationType.milpa,
    LocationType.orchard,
    LocationType.greenhouse,
    LocationType.nursery,
    LocationType.garden,
  }.contains(this);

  /// Mapping from old Spanish Isar-stored enum names to new English names.
  /// Used exclusively by [LocationEnumMigrationService].
  static const Map<String, String> legacyNameMap = {
    'rancho': 'ranch',
    'potrero': 'pasture',
    'monte': 'monte',
    'corral': 'corral',
    'almacenamiento': 'warehouse',
    'aguada': 'pond',
    'siembra': 'field',
    'casa': 'house',
  };
}
