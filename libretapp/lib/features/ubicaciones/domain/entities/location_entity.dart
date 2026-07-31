/// features \u203a ubicaciones \u203a domain \u203a entities \u203a location_entity \u2014 Location domain entity.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_kind.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    this.id,
    required this.uuid,
    required this.name,
    this.kind = LocationKind.instance,
    this.parentUuid,
    this.templateUuid,
    required this.type,
    required this.surfaceArea,
    required this.capacity,
    required this.waterSource,
    required this.terrainType,
    this.status = LocationStatus.available,
    this.category,
    this.geometry,
    this.isShared = false,
    this.isCommunal = false,
    this.imagePaths = const [],
    this.attributes = const [],
    this.inventory = const [],
    this.visits = const [],
    this.waters = const [],
    this.salts = const [],
    this.shades = const [],
    this.pastures = const [],
    this.seedings = const [],
    this.irrigations = const [],
    this.rains = const [],
    this.costs = const [],
    this.crops = const [],
  });
  final int? id;
  final String uuid;
  final String name;
  final LocationKind kind;
  final String? parentUuid;
  final String? templateUuid;
  final LocationType type;
  final double surfaceArea;
  final int capacity;
  final String waterSource;
  final String terrainType;
  final LocationStatus status;

  /// Operational category. If null, derived from [type.category].
  final LocationCategory? category;

  /// GeoJSON geometry string (Point, Polygon, etc.) for GIS integration.
  final String? geometry;

  /// Whether this location is shared among multiple herds/operations.
  final bool isShared;

  /// Whether this is communal/ejido land (affects legal tenure logic).
  final bool isCommunal;

  /// Local file paths or URIs of images attached to this location.
  final List<String> imagePaths;

  final List<DynamicAttribute> attributes;
  final List<InventoryItem> inventory;
  final List<VisitRecord> visits;
  final List<WaterRecord> waters;
  final List<SaltRecord> salts;
  final List<ShadeRecord> shades;
  final List<PastureRecord> pastures;
  final List<SeedingRecord> seedings;
  final List<IrrigationRecord> irrigations;
  final List<RainRecord> rains;
  final List<LocationCostRecord> costs;
  final List<CropRecord> crops;

  /// Effective category: explicit override first, otherwise derived from type.
  LocationCategory get effectiveCategory => category ?? type.category;

  /// Communal ejidal scrubland container (monte comunal).
  bool get isCommunalMonteContainer =>
      type == LocationType.monte && isCommunal;

  /// Whether a location of [childType] may nest under this parent.
  bool canAcceptSubLocationType(LocationType childType) {
    if (childType == LocationType.ejido) {
      return type == LocationType.monte && isCommunal;
    }
    // Root-type locations cannot nest under other locations.
    if (childType.isRootType) return false;
    // Water resources can be placed under any location type.
    if (childType.category == LocationCategory.water) return true;
    // All other non-root types require a root-type parent.
    return type.isRootType;
  }

  LocationEntity copyWith({
    int? id,
    String? uuid,
    String? name,
    LocationKind? kind,
    String? parentUuid,
    String? templateUuid,
    LocationType? type,
    double? surfaceArea,
    int? capacity,
    String? waterSource,
    String? terrainType,
    LocationStatus? status,
    LocationCategory? category,
    String? geometry,
    bool? isShared,
    bool? isCommunal,
    List<String>? imagePaths,
    List<DynamicAttribute>? attributes,
    List<InventoryItem>? inventory,
    List<VisitRecord>? visits,
    List<WaterRecord>? waters,
    List<SaltRecord>? salts,
    List<ShadeRecord>? shades,
    List<PastureRecord>? pastures,
    List<SeedingRecord>? seedings,
    List<IrrigationRecord>? irrigations,
    List<RainRecord>? rains,
    List<LocationCostRecord>? costs,
    List<CropRecord>? crops,
  }) {
    return LocationEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      parentUuid: parentUuid ?? this.parentUuid,
      templateUuid: templateUuid ?? this.templateUuid,
      type: type ?? this.type,
      surfaceArea: surfaceArea ?? this.surfaceArea,
      capacity: capacity ?? this.capacity,
      waterSource: waterSource ?? this.waterSource,
      terrainType: terrainType ?? this.terrainType,
      status: status ?? this.status,
      category: category ?? this.category,
      geometry: geometry ?? this.geometry,
      isShared: isShared ?? this.isShared,
      isCommunal: isCommunal ?? this.isCommunal,
      imagePaths: imagePaths ?? this.imagePaths,
      attributes: attributes ?? this.attributes,
      inventory: inventory ?? this.inventory,
      visits: visits ?? this.visits,
      waters: waters ?? this.waters,
      salts: salts ?? this.salts,
      shades: shades ?? this.shades,
      pastures: pastures ?? this.pastures,
      seedings: seedings ?? this.seedings,
      irrigations: irrigations ?? this.irrigations,
      rains: rains ?? this.rains,
      costs: costs ?? this.costs,
      crops: crops ?? this.crops,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    kind,
    parentUuid,
    templateUuid,
    type,
    surfaceArea,
    capacity,
    waterSource,
    terrainType,
    status,
    category,
    geometry,
    isShared,
    isCommunal,
    imagePaths,
    attributes,
    inventory,
    visits,
    waters,
    salts,
    shades,
    pastures,
    seedings,
    irrigations,
    rains,
    costs,
    crops,
  ];
}
