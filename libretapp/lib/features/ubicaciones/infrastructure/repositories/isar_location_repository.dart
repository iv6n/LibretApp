import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

class IsarLocationRepository implements LocationRepository {
  IsarLocationRepository(this._database);

  final IsarDatabase _database;

  @override
  Stream<List<LocationEntity>> watchAll() async* {
    final isar = await _database.initialize();
    await _ensureSeed(isar);
    yield* isar.isarLocations
        .where()
        .watch(fireImmediately: true)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<List<LocationEntity>> getAll() async {
    final isar = await _database.initialize();
    await _ensureSeed(isar);
    final items = await isar.isarLocations.where().findAll();
    return items.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<LocationEntity?> getByUuid(String uuid) async {
    final isar = await _database.initialize();
    final item = await isar.isarLocations.where().uuidEqualTo(uuid).findFirst();
    return item?.toEntity();
  }

  @override
  Future<void> upsert(LocationEntity location) async {
    final isar = await _database.initialize();
    await isar.writeTxn(() async {
      final existing = await isar.isarLocations
          .where()
          .uuidEqualTo(location.uuid)
          .findFirst();
      final model = location.toIsar(existing?.id);
      await isar.isarLocations.put(model);
    });
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    final isar = await _database.initialize();
    await isar.writeTxn(() async {
      final deleted = await isar.isarLocations.deleteByUuid(uuid);
      LoggerService.i(
        'Ubicacion borrada: $uuid -> $deleted',
        tag: 'IsarLocation',
      );
    });
  }

  @override
  Future<void> addVisit(String uuid, VisitRecord record) async {
    await _modify(uuid, (location) {
      location.visits.add(IsarVisitRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addWater(String uuid, WaterRecord record) async {
    await _modify(uuid, (location) {
      location.waters.add(IsarWaterRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addPasture(String uuid, PastureRecord record) async {
    await _modify(uuid, (location) {
      location.pastures.add(IsarPastureRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addSeeding(String uuid, SeedingRecord record) async {
    await _modify(uuid, (location) {
      location.seedings.add(IsarSeedingRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addIrrigation(String uuid, IrrigationRecord record) async {
    await _modify(uuid, (location) {
      location.irrigations.add(IsarIrrigationRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addRain(String uuid, RainRecord record) async {
    await _modify(uuid, (location) {
      location.rains.add(IsarRainRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addCost(String uuid, CostRecord record) async {
    await _modify(uuid, (location) {
      location.costs.add(IsarLocationCostRecord.fromEntity(record));
    });
  }

  Future<void> _modify(String uuid, void Function(IsarLocation) updater) async {
    final isar = await _database.initialize();
    await isar.writeTxn(() async {
      final location = await isar.isarLocations
          .where()
          .uuidEqualTo(uuid)
          .findFirst();
      if (location == null) {
        throw StateError('Ubicacion $uuid no encontrada');
      }
      updater(location);
      await isar.isarLocations.put(location);
    });
  }

  Future<void> _ensureSeed(Isar isar) async {
    final count = await isar.isarLocations.count();
    if (count > 0) return;

    final now = DateTime.now();
    final seeds = [
      LocationEntity(
        uuid: 'monte',
        name: 'Monte',
        type: LocationType.potrero,
        surfaceArea: 45.8,
        capacity: 120,
        waterSource: 'Arroyo natural',
        terrainType: 'Montañoso con pastizal',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 4)),
            animals: 98,
            notes: 'Inspección de cercas en zona alta',
          ),
          VisitRecord(
            date: now.subtract(const Duration(days: 11)),
            animals: 95,
            notes: 'Conteo de hacienda',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 2)),
            level: 68,
            type: WaterType.pozo,
            notes: 'Nivel adecuado post-lluvia',
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 5)),
            grassType: 'Pasto natural mixto con flechilla',
            condition: 'Vegetación exuberante por estación',
            carryingCapacity: 2.6,
          ),
        ],
        rains: [
          RainRecord(
            date: now.subtract(const Duration(days: 2)),
            millimeters: 22,
            location: 'Monte',
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 25)),
            maintenance: 300,
            fences: 150,
            repairs: 80,
            labor: 200,
            total: 730,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'potrero',
        name: 'Potrero',
        type: LocationType.potrero,
        surfaceArea: 32.5,
        capacity: 95,
        waterSource: 'Perforación con molino',
        terrainType: 'Plano con ligeras depresiones',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 1)),
            animals: 78,
            notes: 'Movimiento de hacienda desde Rancho',
          ),
          VisitRecord(
            date: now.subtract(const Duration(days: 8)),
            animals: 75,
            notes: 'Rotación periódica',
          ),
          VisitRecord(
            date: now.subtract(const Duration(days: 15)),
            animals: 82,
            notes: 'Inspección de alambrado',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 1)),
            level: 75,
            type: WaterType.pozo,
            notes: 'Sistema automático en funcionamiento',
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 3)),
            grassType: 'Brachiaria Brizantha + Estrella africana',
            condition: 'Muy bueno - pastoreo rotativo',
            carryingCapacity: 2.9,
          ),
        ],
        irrigations: [
          IrrigationRecord(
            date: now.subtract(const Duration(days: 10)),
            type: 'Riego por goteo (suplementario)',
            duration: const Duration(hours: 2),
            cost: 45,
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 18)),
            maintenance: 200,
            fences: 120,
            repairs: 30,
            labor: 100,
            total: 450,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'rancho-trabajo',
        name: 'Rancho',
        type: LocationType.rancho,
        surfaceArea: 8.5,
        capacity: 50,
        waterSource: 'Tanque elevado + perforación',
        terrainType: 'Compactado - acceso vehicular',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 0)),
            animals: 32,
            notes: 'Animales en descanso y trabajo',
          ),
          VisitRecord(
            date: now.subtract(const Duration(days: 6)),
            animals: 28,
            notes: 'Manejo sanitario',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 0)),
            level: 92,
            type: WaterType.pila,
            notes: 'Tanque lleno - suficiente para operaciones',
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 8)),
            grassType: 'Pasto de corta para henificado',
            condition: 'Mantenido para suplemento',
            carryingCapacity: 1.2,
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 7)),
            maintenance: 180,
            fences: 60,
            repairs: 120,
            labor: 250,
            total: 610,
          ),
        ],
      ),
    ];

    await isar.writeTxn(() async {
      await isar.isarLocations.putAll(seeds.map((e) => e.toIsar()).toList());
    });

    LoggerService.i('Seeded ubicaciones demo data', tag: 'IsarLocation');
  }
}
