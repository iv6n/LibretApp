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
        uuid: 'potrero-a',
        name: 'Potrero A',
        type: LocationType.potrero,
        surfaceArea: 12.5,
        capacity: 40,
        waterSource: 'Pozo',
        terrainType: 'Plano',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 2)),
            animals: 38,
            notes: 'Rotación principal',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 1)),
            level: 72,
            type: WaterType.pozo,
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 7)),
            grassType: 'Brachiaria',
            condition: 'Rebrote vigoroso',
            carryingCapacity: 3.5,
          ),
        ],
        rains: [
          RainRecord(
            date: now.subtract(const Duration(days: 3)),
            millimeters: 12,
            location: 'Potrero A',
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 12)),
            maintenance: 120,
            fences: 0,
            repairs: 0,
            labor: 80,
            total: 200,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'potrero-b',
        name: 'Potrero B',
        type: LocationType.potrero,
        surfaceArea: 18.0,
        capacity: 55,
        waterSource: 'Pozo y represo',
        terrainType: 'Ligeramente ondulado',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 5)),
            animals: 42,
            notes: 'Revisión de alambrado',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 2)),
            level: 65,
            type: WaterType.pozo,
            notes: 'Recarga parcial',
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 10)),
            grassType: 'Estrella africana',
            condition: 'Parejo',
            carryingCapacity: 3.0,
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 20)),
            maintenance: 90,
            fences: 60,
            repairs: 40,
            labor: 50,
            total: 240,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'potrero-c',
        name: 'Potrero C',
        type: LocationType.potrero,
        surfaceArea: 9.8,
        capacity: 32,
        waterSource: 'Represo',
        terrainType: 'Semi ondulado',
        status: 'activo',
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 4)),
            level: 58,
            type: WaterType.represo,
            notes: 'Nivel a vigilar en verano',
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 14)),
            grassType: 'Panicum',
            condition: 'Buen porte',
            carryingCapacity: 2.8,
          ),
        ],
        rains: [
          RainRecord(
            date: now.subtract(const Duration(days: 9)),
            millimeters: 8,
            location: 'Potrero C',
          ),
        ],
      ),
      LocationEntity(
        uuid: 'potrero-d',
        name: 'Potrero D',
        type: LocationType.potrero,
        surfaceArea: 7.2,
        capacity: 22,
        waterSource: 'Pila móvil',
        terrainType: 'Ligeramente arcilloso',
        status: 'activo',
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 3)),
            level: 60,
            type: WaterType.pila,
          ),
        ],
        pastures: [
          PastureRecord(
            date: now.subtract(const Duration(days: 11)),
            grassType: 'Brachiaria + trébol',
            condition: 'Mixto, requiere descanso',
            carryingCapacity: 2.1,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'feedlot-1',
        name: 'Feedlot 1',
        type: LocationType.corral,
        surfaceArea: 4.5,
        capacity: 80,
        waterSource: 'Bebederos automáticos',
        terrainType: 'Estabilizado',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 1)),
            animals: 74,
            notes: 'Chequeo de comederos',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 1)),
            level: 85,
            type: WaterType.pila,
            notes: 'Nivel óptimo',
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 15)),
            maintenance: 140,
            fences: 45,
            repairs: 110,
            labor: 160,
            total: 455,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'corral-crias',
        name: 'Corral Crías',
        type: LocationType.corral,
        surfaceArea: 2.4,
        capacity: 35,
        waterSource: 'Pila',
        terrainType: 'Firme',
        status: 'activo',
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 2)),
            level: 78,
            type: WaterType.pila,
          ),
        ],
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 4)),
            animals: 26,
            notes: 'Chequeo de destetes',
          ),
        ],
      ),
      LocationEntity(
        uuid: 'rancho-trabajo',
        name: 'Rancho de Trabajo',
        type: LocationType.rancho,
        surfaceArea: 1.8,
        capacity: 15,
        waterSource: 'Bebedero',
        terrainType: 'Compactado',
        status: 'activo',
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 6)),
            animals: 6,
            notes: 'Caballos de trabajo',
          ),
        ],
      ),
      LocationEntity(
        uuid: 'gallinero-central',
        name: 'Gallinero Central',
        type: LocationType.corral,
        surfaceArea: 0.9,
        capacity: 120,
        waterSource: 'Bebederos',
        terrainType: 'Piso elevado',
        status: 'activo',
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 1)),
            level: 90,
            type: WaterType.pila,
            notes: 'Limpieza semanal',
          ),
        ],
      ),
      LocationEntity(
        uuid: 'siembra-alfalfa',
        name: 'Siembra de Alfalfa',
        type: LocationType.siembra,
        surfaceArea: 6.0,
        capacity: 0,
        waterSource: 'Riego rodado',
        terrainType: 'Plano',
        status: 'en-siembra',
        seedings: [
          SeedingRecord(
            date: now.subtract(const Duration(days: 20)),
            crop: 'Alfalfa',
            surface: 6.0,
            cost: 850,
          ),
        ],
        irrigations: [
          IrrigationRecord(
            date: now.subtract(const Duration(days: 2)),
            type: 'Aspersión',
            duration: const Duration(minutes: 90),
            cost: 120,
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
