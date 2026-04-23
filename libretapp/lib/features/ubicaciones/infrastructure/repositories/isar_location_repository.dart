import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
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
    yield* isar.isarLocations
        .where()
        .watch(fireImmediately: true)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<List<LocationEntity>> getAll() async {
    final isar = await _database.initialize();
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
      final previousParent = existing?.parentUuid;
      final model = location.toIsar(existing?.id);
      await isar.isarLocations.put(model);

      if (previousParent != location.parentUuid && previousParent != null) {
        final oldParent = await isar.isarLocations
            .where()
            .uuidEqualTo(previousParent)
            .findFirst();
        if (oldParent != null) {
          oldParent.childUuids.remove(location.uuid);
          await isar.isarLocations.put(oldParent);
        }
      }

      if (location.parentUuid != null) {
        final parent = await isar.isarLocations
            .where()
            .uuidEqualTo(location.parentUuid!)
            .findFirst();
        if (parent != null && !parent.childUuids.contains(location.uuid)) {
          parent.childUuids.add(location.uuid);
          await isar.isarLocations.put(parent);
        }
      }
    });
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    final isar = await _database.initialize();
    await isar.writeTxn(() async {
      final location = await isar.isarLocations
          .where()
          .uuidEqualTo(uuid)
          .findFirst();
      if (location?.parentUuid != null) {
        final parent = await isar.isarLocations
            .where()
            .uuidEqualTo(location!.parentUuid!)
            .findFirst();
        if (parent != null) {
          parent.childUuids.remove(uuid);
          await isar.isarLocations.put(parent);
        }
      }

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
  Future<void> addSalt(String uuid, SaltRecord record) async {
    await _modify(uuid, (location) {
      location.salts.add(IsarSaltRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addShade(String uuid, ShadeRecord record) async {
    await _modify(uuid, (location) {
      location.shades.add(IsarShadeRecord.fromEntity(record));
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

  @override
  Future<void> addCrop(String locationUuid, CropRecord crop) async {
    await _modify(locationUuid, (location) {
      location.crops.add(IsarCropRecord.fromEntity(crop));
    });
  }

  @override
  Future<void> updateCrop(String locationUuid, CropRecord crop) async {
    await _modify(locationUuid, (location) {
      final index = location.crops.indexWhere((c) => c.uuid == crop.uuid);
      if (index == -1) {
        throw StateError('Cultivo ${crop.uuid} no encontrado');
      }
      location.crops[index] = IsarCropRecord.fromEntity(crop);
    });
  }

  @override
  Future<void> deleteCrop(String locationUuid, String cropUuid) async {
    await _modify(locationUuid, (location) {
      location.crops.removeWhere((c) => c.uuid == cropUuid);
    });
  }

  @override
  Future<void> addHarvest(
    String locationUuid,
    String cropUuid,
    HarvestRecord record,
  ) async {
    await _modifyCrop(locationUuid, cropUuid, (crop) {
      crop.harvests.add(IsarHarvestRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addCropWatering(
    String locationUuid,
    String cropUuid,
    CropWateringRecord record,
  ) async {
    await _modifyCrop(locationUuid, cropUuid, (crop) {
      crop.waterings.add(IsarCropWateringRecord.fromEntity(record));
      crop.lastWateredDate = record.date;
    });
  }

  @override
  Future<void> addCropHealth(
    String locationUuid,
    String cropUuid,
    CropHealthRecord record,
  ) async {
    await _modifyCrop(locationUuid, cropUuid, (crop) {
      crop.healthRecords.add(IsarCropHealthRecord.fromEntity(record));
    });
  }

  @override
  Future<void> addCropTask(
    String locationUuid,
    String cropUuid,
    CropTask task,
  ) async {
    await _modifyCrop(locationUuid, cropUuid, (crop) {
      crop.tasks.add(IsarCropTask.fromEntity(task));
    });
  }

  @override
  Future<void> completeCropTask(
    String locationUuid,
    String cropUuid,
    String taskUuid,
  ) async {
    await _modifyCrop(locationUuid, cropUuid, (crop) {
      final index = crop.tasks.indexWhere((t) => t.uuid == taskUuid);
      if (index == -1) {
        throw StateError('Tarea $taskUuid no encontrada');
      }
      crop.tasks[index].completed = true;
    });
  }

  Future<void> _modifyCrop(
    String locationUuid,
    String cropUuid,
    void Function(IsarCropRecord) updater,
  ) async {
    await _modify(locationUuid, (location) {
      final crop = location.crops.where((c) => c.uuid == cropUuid).firstOrNull;
      if (crop == null) {
        throw StateError('Cultivo $cropUuid no encontrado');
      }
      updater(crop);
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
        parentUuid: 'rancho-trabajo',
        type: LocationType.potrero,
        surfaceArea: 45.8,
        capacity: 120,
        waterSource: 'Arroyo natural',
        terrainType: 'Montañoso con pastizal',
        status: 'activo',
        attributes: [
          DynamicAttribute.number(
            key: 'agua',
            label: 'Agua disponible',
            value: 68,
            unit: '%',
          ),
          DynamicAttribute.number(
            key: 'pastura',
            label: 'Pastura',
            value: 80,
            unit: '%',
          ),
          DynamicAttribute.integer(
            key: 'animales',
            label: 'Animales',
            value: 98,
          ),
          DynamicAttribute.number(
            key: 'capacidad',
            label: 'Capacidad',
            value: 120,
          ),
        ],
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
        salts: [
          SaltRecord(
            date: now.subtract(const Duration(days: 3)),
            quantityKg: 120,
            notes: 'Mineralizada, repuesto reciente',
          ),
        ],
        shades: [
          ShadeRecord(
            date: now.subtract(const Duration(days: 5)),
            shadePercent: 45,
            condition: 'Árboles nativos, sombra moderada',
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
        parentUuid: 'rancho-trabajo',
        type: LocationType.potrero,
        surfaceArea: 32.5,
        capacity: 95,
        waterSource: 'Perforación con molino',
        terrainType: 'Plano con ligeras depresiones',
        status: 'activo',
        attributes: [
          DynamicAttribute.number(
            key: 'agua',
            label: 'Agua disponible',
            value: 75,
            unit: '%',
          ),
          DynamicAttribute.number(
            key: 'pastura',
            label: 'Pastura',
            value: 78,
            unit: '%',
          ),
          DynamicAttribute.integer(
            key: 'animales',
            label: 'Animales',
            value: 78,
          ),
          DynamicAttribute.number(
            key: 'capacidad',
            label: 'Capacidad',
            value: 95,
          ),
        ],
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
        salts: [
          SaltRecord(
            date: now.subtract(const Duration(days: 2)),
            quantityKg: 80,
            notes: 'Bloques parciales, reponer en 4 días',
          ),
        ],
        shades: [
          ShadeRecord(
            date: now.subtract(const Duration(days: 6)),
            shadePercent: 35,
            condition: 'Malla sombra parcial, buen estado',
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
        uuid: 'milpa-alfalfa',
        name: 'Milpa Alfalfa Norte',
        parentUuid: 'rancho-trabajo',
        type: LocationType.siembra,
        surfaceArea: 18.2,
        capacity: 0,
        waterSource: 'Canal de riego',
        terrainType: 'Franco arcilloso',
        status: 'activo',
        attributes: [
          DynamicAttribute.number(
            key: 'crecimiento_pct',
            label: 'Crecimiento',
            value: 74,
            unit: '%',
          ),
          DynamicAttribute.text(
            key: 'ciclo_cosecha',
            label: 'Ciclo de cosecha',
            value: '65 días',
          ),
          DynamicAttribute.number(
            key: 'agua',
            label: 'Agua disponible',
            value: 81,
            unit: '%',
          ),
        ],
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 2)),
            animals: 0,
            notes: 'Revisión de brote parejo',
          ),
        ],
        seedings: [
          SeedingRecord(
            date: now.subtract(const Duration(days: 34)),
            crop: 'Alfalfa',
            surface: 18.2,
            cost: 6400,
          ),
        ],
        irrigations: [
          IrrigationRecord(
            date: now.subtract(const Duration(days: 1)),
            type: 'Aspersión',
            duration: const Duration(hours: 3),
            cost: 180,
          ),
          IrrigationRecord(
            date: now.subtract(const Duration(days: 6)),
            type: 'Aspersión',
            duration: const Duration(hours: 2, minutes: 30),
            cost: 160,
          ),
        ],
        rains: [
          RainRecord(
            date: now.subtract(const Duration(days: 3)),
            millimeters: 16,
            location: 'Milpa Alfalfa Norte',
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 5)),
            maintenance: 90,
            fences: 0,
            repairs: 40,
            labor: 220,
            total: 350,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'corral-engorda',
        name: 'Corral de Engorda',
        parentUuid: 'rancho-trabajo',
        type: LocationType.corral,
        surfaceArea: 5.4,
        capacity: 64,
        waterSource: 'Bebedero automático',
        terrainType: 'Concreto con cama seca',
        status: 'activo',
        attributes: [
          DynamicAttribute.number(
            key: 'ganancia_diaria',
            label: 'Ganancia diaria',
            value: 1.35,
            unit: 'kg/día',
          ),
          DynamicAttribute.text(
            key: 'dieta',
            label: 'Dieta',
            value: 'Finalización 14% proteína + silo',
          ),
          DynamicAttribute.number(
            key: 'agua',
            label: 'Agua disponible',
            value: 88,
            unit: '%',
          ),
        ],
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 1)),
            animals: 42,
            notes: 'Monitoreo de consumo y lote de salida',
          ),
          VisitRecord(
            date: now.subtract(const Duration(days: 7)),
            animals: 39,
            notes: 'Ajuste de dieta de finalización',
          ),
        ],
        waters: [
          WaterRecord(
            date: now.subtract(const Duration(days: 1)),
            level: 88,
            type: WaterType.pila,
            notes: 'Línea de bebederos presurizada',
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 3)),
            maintenance: 120,
            fences: 0,
            repairs: 65,
            labor: 140,
            total: 325,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'almacen-equipo',
        name: 'Almacén de Equipo',
        parentUuid: 'rancho-trabajo',
        type: LocationType.rancho,
        surfaceArea: 1.2,
        capacity: 0,
        waterSource: 'No aplica',
        terrainType: 'Nave techada',
        status: 'activo',
        attributes: [
          DynamicAttribute.text(
            key: 'equipos',
            label: 'Equipo principal',
            value: 'Monturas, piolas, herramienta y herrajes',
          ),
          DynamicAttribute.integer(
            key: 'inventario_total',
            label: 'Piezas',
            value: 127,
          ),
          DynamicAttribute.number(
            key: 'agua',
            label: 'Agua disponible',
            value: 0,
            unit: '%',
          ),
        ],
        visits: [
          VisitRecord(
            date: now.subtract(const Duration(days: 3)),
            animals: 0,
            notes: 'Inventario semanal de equipo de trabajo',
          ),
        ],
        costs: [
          CostRecord(
            date: now.subtract(const Duration(days: 12)),
            maintenance: 180,
            fences: 0,
            repairs: 240,
            labor: 120,
            total: 540,
          ),
        ],
      ),
      LocationEntity(
        uuid: 'rancho-trabajo',
        name: 'Rancho',
        childUuids: const [
          'monte',
          'potrero',
          'milpa-alfalfa',
          'corral-engorda',
          'almacen-equipo',
        ],
        type: LocationType.rancho,
        surfaceArea: 8.5,
        capacity: 50,
        waterSource: 'Tanque elevado + perforación',
        terrainType: 'Compactado - acceso vehicular',
        status: 'activo',
        attributes: [
          DynamicAttribute.number(
            key: 'agua',
            label: 'Agua disponible',
            value: 92,
            unit: '%',
          ),
          DynamicAttribute.number(
            key: 'sombra',
            label: 'Sombra',
            value: 60,
            unit: '%',
          ),
          DynamicAttribute.integer(
            key: 'animales',
            label: 'Animales',
            value: 32,
          ),
          DynamicAttribute.number(
            key: 'capacidad',
            label: 'Capacidad',
            value: 50,
          ),
          DynamicAttribute.number(
            key: 'inventario_alimento',
            label: 'Inventario alimento',
            value: 18,
            unit: 'bultos',
          ),
        ],
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
        salts: [
          SaltRecord(
            date: now.subtract(const Duration(days: 4)),
            quantityKg: 40,
            notes: 'Bloques en corral, consumo moderado',
          ),
        ],
        shades: [
          ShadeRecord(
            date: now.subtract(const Duration(days: 1)),
            shadePercent: 60,
            condition: 'Techos y árboles, buena cobertura',
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
