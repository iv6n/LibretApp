import 'package:isar/isar.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';

part 'isar_location.g.dart';

@collection
class IsarLocation {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late String type;
  late double surfaceArea;
  late int capacity;
  late String waterSource;
  late String terrainType;
  late String status;

  List<IsarVisitRecord> visits = [];
  List<IsarWaterRecord> waters = [];
  List<IsarPastureRecord> pastures = [];
  List<IsarSeedingRecord> seedings = [];
  List<IsarIrrigationRecord> irrigations = [];
  List<IsarRainRecord> rains = [];
  List<IsarLocationCostRecord> costs = [];
}

@embedded
class IsarVisitRecord {
  late DateTime date;
  late int animals;
  String? notes;
  String? user;

  VisitRecord toEntity() =>
      VisitRecord(date: date, animals: animals, notes: notes, user: user);

  static IsarVisitRecord fromEntity(VisitRecord record) => IsarVisitRecord()
    ..date = record.date
    ..animals = record.animals
    ..notes = record.notes
    ..user = record.user;
}

@embedded
class IsarWaterRecord {
  late DateTime date;
  late double level;
  late String type;
  String? notes;

  WaterRecord toEntity() => WaterRecord(
    date: date,
    level: level,
    type: _enumByName(WaterType.values, type),
    notes: notes,
  );

  static IsarWaterRecord fromEntity(WaterRecord record) => IsarWaterRecord()
    ..date = record.date
    ..level = record.level
    ..type = record.type.name
    ..notes = record.notes;
}

@embedded
class IsarPastureRecord {
  late DateTime date;
  late String grassType;
  late String condition;
  late double carryingCapacity;

  PastureRecord toEntity() => PastureRecord(
    date: date,
    grassType: grassType,
    condition: condition,
    carryingCapacity: carryingCapacity,
  );

  static IsarPastureRecord fromEntity(PastureRecord record) =>
      IsarPastureRecord()
        ..date = record.date
        ..grassType = record.grassType
        ..condition = record.condition
        ..carryingCapacity = record.carryingCapacity;
}

@embedded
class IsarSeedingRecord {
  late DateTime date;
  late String crop;
  late double surface;
  late double cost;

  SeedingRecord toEntity() =>
      SeedingRecord(date: date, crop: crop, surface: surface, cost: cost);

  static IsarSeedingRecord fromEntity(SeedingRecord record) =>
      IsarSeedingRecord()
        ..date = record.date
        ..crop = record.crop
        ..surface = record.surface
        ..cost = record.cost;
}

@embedded
class IsarIrrigationRecord {
  late DateTime date;
  late String type;
  late int durationMinutes;
  late double cost;

  IrrigationRecord toEntity() => IrrigationRecord(
    date: date,
    type: type,
    duration: Duration(minutes: durationMinutes),
    cost: cost,
  );

  static IsarIrrigationRecord fromEntity(IrrigationRecord record) =>
      IsarIrrigationRecord()
        ..date = record.date
        ..type = record.type
        ..durationMinutes = record.duration.inMinutes
        ..cost = record.cost;
}

@embedded
class IsarRainRecord {
  late DateTime date;
  late double millimeters;
  late String location;

  RainRecord toEntity() =>
      RainRecord(date: date, millimeters: millimeters, location: location);

  static IsarRainRecord fromEntity(RainRecord record) => IsarRainRecord()
    ..date = record.date
    ..millimeters = record.millimeters
    ..location = record.location;
}

@embedded
class IsarLocationCostRecord {
  late DateTime date;
  late double maintenance;
  late double fences;
  late double repairs;
  late double labor;
  late double total;

  CostRecord toEntity() => CostRecord(
    date: date,
    maintenance: maintenance,
    fences: fences,
    repairs: repairs,
    labor: labor,
    total: total,
  );

  static IsarLocationCostRecord fromEntity(CostRecord record) =>
      IsarLocationCostRecord()
        ..date = record.date
        ..maintenance = record.maintenance
        ..fences = record.fences
        ..repairs = record.repairs
        ..labor = record.labor
        ..total = record.total;
}

extension IsarLocationMapper on IsarLocation {
  LocationEntity toEntity() {
    return LocationEntity(
      id: id.isarId,
      uuid: uuid,
      name: name,
      type: _enumByName(LocationType.values, type),
      surfaceArea: surfaceArea,
      capacity: capacity,
      waterSource: waterSource,
      terrainType: terrainType,
      status: status,
      visits: visits.map((e) => e.toEntity()).toList(growable: false),
      waters: waters.map((e) => e.toEntity()).toList(growable: false),
      pastures: pastures.map((e) => e.toEntity()).toList(growable: false),
      seedings: seedings.map((e) => e.toEntity()).toList(growable: false),
      irrigations: irrigations.map((e) => e.toEntity()).toList(growable: false),
      rains: rains.map((e) => e.toEntity()).toList(growable: false),
      costs: costs.map((e) => e.toEntity()).toList(growable: false),
    );
  }
}

extension LocationEntityToIsar on LocationEntity {
  IsarLocation toIsar([Id? existingId]) {
    final model = IsarLocation()
      ..uuid = uuid
      ..name = name
      ..type = type.name
      ..surfaceArea = surfaceArea
      ..capacity = capacity
      ..waterSource = waterSource
      ..terrainType = terrainType
      ..status = status
      ..visits = visits.map(IsarVisitRecord.fromEntity).toList()
      ..waters = waters.map(IsarWaterRecord.fromEntity).toList()
      ..pastures = pastures.map(IsarPastureRecord.fromEntity).toList()
      ..seedings = seedings.map(IsarSeedingRecord.fromEntity).toList()
      ..irrigations = irrigations.map(IsarIrrigationRecord.fromEntity).toList()
      ..rains = rains.map(IsarRainRecord.fromEntity).toList()
      ..costs = costs.map(IsarLocationCostRecord.fromEntity).toList();

    if (existingId != null && existingId != Isar.autoIncrement) {
      model.id = existingId;
    } else if (id != null) {
      model.id = id!;
    }
    return model;
  }
}

T _enumByName<T extends Enum>(List<T> values, String name) =>
    values.byName(name);

extension on Id {
  int? get isarId => this == Isar.autoIncrement ? null : this;
}
