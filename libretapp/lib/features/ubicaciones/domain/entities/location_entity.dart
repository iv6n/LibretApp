import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

class LocationEntity extends Equatable {
  final int? id;
  final String uuid;
  final String name;
  final LocationType type;
  final double surfaceArea;
  final int capacity;
  final String waterSource;
  final String terrainType;
  final String status;
  final List<VisitRecord> visits;
  final List<WaterRecord> waters;
  final List<PastureRecord> pastures;
  final List<SeedingRecord> seedings;
  final List<IrrigationRecord> irrigations;
  final List<RainRecord> rains;
  final List<CostRecord> costs;

  const LocationEntity({
    this.id,
    required this.uuid,
    required this.name,
    required this.type,
    required this.surfaceArea,
    required this.capacity,
    required this.waterSource,
    required this.terrainType,
    required this.status,
    this.visits = const [],
    this.waters = const [],
    this.pastures = const [],
    this.seedings = const [],
    this.irrigations = const [],
    this.rains = const [],
    this.costs = const [],
  });

  LocationEntity copyWith({
    int? id,
    String? uuid,
    String? name,
    LocationType? type,
    double? surfaceArea,
    int? capacity,
    String? waterSource,
    String? terrainType,
    String? status,
    List<VisitRecord>? visits,
    List<WaterRecord>? waters,
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
      type: type ?? this.type,
      surfaceArea: surfaceArea ?? this.surfaceArea,
      capacity: capacity ?? this.capacity,
      waterSource: waterSource ?? this.waterSource,
      terrainType: terrainType ?? this.terrainType,
      status: status ?? this.status,
      visits: visits ?? this.visits,
      waters: waters ?? this.waters,
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
    type,
    surfaceArea,
    capacity,
    waterSource,
    terrainType,
    status,
    visits,
    waters,
    pastures,
    seedings,
    irrigations,
    rains,
    costs,
  ];
}
