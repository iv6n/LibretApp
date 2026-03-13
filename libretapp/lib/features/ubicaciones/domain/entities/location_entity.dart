import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_kind.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    this.id,
    required this.uuid,
    required this.name,
    this.kind = LocationKind.instance,
    this.parentUuid,
    this.childUuids = const [],
    this.templateUuid,
    required this.type,
    required this.surfaceArea,
    required this.capacity,
    required this.waterSource,
    required this.terrainType,
    required this.status,
    this.attributes = const [],
    this.visits = const [],
    this.waters = const [],
    this.salts = const [],
    this.shades = const [],
    this.pastures = const [],
    this.seedings = const [],
    this.irrigations = const [],
    this.rains = const [],
    this.costs = const [],
  });
  final int? id;
  final String uuid;
  final String name;
  final LocationKind kind;
  final String? parentUuid;
  final List<String> childUuids;
  final String? templateUuid;
  final LocationType type;
  final double surfaceArea;
  final int capacity;
  final String waterSource;
  final String terrainType;
  final String status;
  final List<DynamicAttribute> attributes;
  final List<VisitRecord> visits;
  final List<WaterRecord> waters;
  final List<SaltRecord> salts;
  final List<ShadeRecord> shades;
  final List<PastureRecord> pastures;
  final List<SeedingRecord> seedings;
  final List<IrrigationRecord> irrigations;
  final List<RainRecord> rains;
  final List<CostRecord> costs;

  LocationEntity copyWith({
    int? id,
    String? uuid,
    String? name,
    LocationKind? kind,
    String? parentUuid,
    List<String>? childUuids,
    String? templateUuid,
    LocationType? type,
    double? surfaceArea,
    int? capacity,
    String? waterSource,
    String? terrainType,
    String? status,
    List<DynamicAttribute>? attributes,
    List<VisitRecord>? visits,
    List<WaterRecord>? waters,
    List<SaltRecord>? salts,
    List<ShadeRecord>? shades,
    List<PastureRecord>? pastures,
    List<SeedingRecord>? seedings,
    List<IrrigationRecord>? irrigations,
    List<RainRecord>? rains,
    List<CostRecord>? costs,
  }) {
    return LocationEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      parentUuid: parentUuid ?? this.parentUuid,
      childUuids: childUuids ?? this.childUuids,
      templateUuid: templateUuid ?? this.templateUuid,
      type: type ?? this.type,
      surfaceArea: surfaceArea ?? this.surfaceArea,
      capacity: capacity ?? this.capacity,
      waterSource: waterSource ?? this.waterSource,
      terrainType: terrainType ?? this.terrainType,
      status: status ?? this.status,
      attributes: attributes ?? this.attributes,
      visits: visits ?? this.visits,
      waters: waters ?? this.waters,
      salts: salts ?? this.salts,
      shades: shades ?? this.shades,
      pastures: pastures ?? this.pastures,
      seedings: seedings ?? this.seedings,
      irrigations: irrigations ?? this.irrigations,
      rains: rains ?? this.rains,
      costs: costs ?? this.costs,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    kind,
    parentUuid,
    childUuids,
    templateUuid,
    type,
    surfaceArea,
    capacity,
    waterSource,
    terrainType,
    status,
    attributes,
    visits,
    waters,
    salts,
    shades,
    pastures,
    seedings,
    irrigations,
    rains,
    costs,
  ];
}
