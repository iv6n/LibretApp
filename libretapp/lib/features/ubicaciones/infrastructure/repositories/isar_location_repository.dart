/// features \u203a ubicaciones \u203a infrastructure \u203a repositories \u203a isar_location_repository \u2014 Isar implementation of LocationRepository.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';

import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

const _resetLocationSeed = bool.fromEnvironment('LIBRET_RESET_LOCATION_SEED');

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
      final previousParent = existing?.parentUuid;
      final model = location.toIsar(existing?.id);
      await isar.isarLocations.put(model);

      if (previousParent != location.parentUuid && previousParent != null) {
        // No childUuids maintenance needed — parentUuid is the source of truth.
      }

      if (location.parentUuid != null) {
        // Parent relationship maintained via parentUuid only.
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
        // Parent relationship maintained via parentUuid only.
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

  // ── Inventory management ─────────────────────────────────────────────

  @override
  Future<void> addInventoryItem(String locationUuid, InventoryItem item) async {
    await _modify(locationUuid, (location) {
      location.inventory.add(IsarInventoryItem.fromEntity(item));
    });
  }

  @override
  Future<void> updateInventoryItem(
    String locationUuid,
    InventoryItem item,
  ) async {
    await _modify(locationUuid, (location) {
      final index = location.inventory.indexWhere((i) => i.uuid == item.uuid);
      if (index == -1) {
        throw StateError('Artículo ${item.uuid} no encontrado');
      }
      location.inventory[index] = IsarInventoryItem.fromEntity(item);
    });
  }

  @override
  Future<void> removeInventoryItem(String locationUuid, String itemUuid) async {
    await _modify(locationUuid, (location) {
      location.inventory.removeWhere((i) => i.uuid == itemUuid);
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
    if (count > 0) await _migrateEjidoParentIfNeeded(isar);
    if (count > 0 && !_resetLocationSeed) return;

    if (count > 0 && _resetLocationSeed) {
      await isar.writeTxn(() async {
        await isar.isarLocations.clear();
      });
      LoggerService.w(
        'LIBRET_RESET_LOCATION_SEED activo: ubicaciones locales limpiadas',
        tag: 'IsarLocation',
      );
    }

    final now = DateTime.now();
    // ── Root locations ─────────────────────────────────────────────────────
    final propCasa = LocationEntity(
      uuid: 'prop-casa',
      name: 'Propiedad Casa',
      type: LocationType.homestead,
      surfaceArea: 0.5,
      capacity: 5,
      waterSource: 'Toma municipal',
      terrainType: 'Compactado',
      status: LocationStatus.available,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 1)),
          animals: 2,
          notes: 'Revisión general',
        ),
      ],
    );

    final milpaProp = LocationEntity(
      uuid: 'milpa-prop',
      name: 'Propiedad Milpa',
      type: LocationType.finca,
      surfaceArea: 6.0,
      capacity: 18,
      waterSource: 'Aguadas propias',
      terrainType: 'Franco arcilloso',
      status: LocationStatus.available,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 2)),
          animals: 0,
          notes: 'Revisión cultivos y corrales',
        ),
      ],
      costs: [
        CostRecord(
          date: now.subtract(const Duration(days: 14)),
          maintenance: 300,
          fences: 150,
          repairs: 0,
          labor: 200,
          total: 650,
        ),
      ],
    );

    final ejidoDerecho = LocationEntity(
      uuid: 'ejido-derecho',
      name: 'Derecho Ejidal',
      parentUuid: 'monte-ejidal',
      type: LocationType.ejido,
      surfaceArea: 0,
      capacity: 20,
      waterSource: 'Sistemas de agua comunal',
      terrainType: 'Monte comunal',
      status: LocationStatus.available,
      isCommunal: true,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 5)),
          animals: 18,
          notes: 'Conteo en agostadero',
        ),
      ],
    );

    final monteEjidal = LocationEntity(
      uuid: 'monte-ejidal',
      name: 'Monte Ejidal Comunal',
      type: LocationType.monte,
      surfaceArea: 1000,
      capacity: 300,
      waterSource: '5 presas + 3 manantiales naturales',
      terrainType: 'Lomeríos con monte nativo',
      status: LocationStatus.available,
      isCommunal: true,
      isShared: true,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 7)),
          animals: 0,
          notes: 'Inspección comunal de linderos',
        ),
      ],
    );

    // ── Home property children ──────────────────────────────────────────────
    final casaHouse = LocationEntity(
      uuid: 'casa-house',
      name: 'Casa',
      parentUuid: 'prop-casa',
      type: LocationType.house,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Toma municipal',
      terrainType: 'Construcción',
      status: LocationStatus.inUse,
    );

    final casaBodega = LocationEntity(
      uuid: 'casa-bodega',
      name: 'Bodega Heno / Herramientas',
      parentUuid: 'prop-casa',
      type: LocationType.warehouse,
      surfaceArea: 0,
      capacity: 0,
      waterSource: '',
      terrainType: 'Nave techada',
      status: LocationStatus.inUse,
      inventory: [
        InventoryItem(
          uuid: 'item-heno-1',
          name: 'Pacas de heno',
          category: InventoryCategory.feed,
          quantity: 40,
          unit: 'paca',
          notes: 'Heno de alfalfa',
        ),
        InventoryItem(
          uuid: 'item-tool-1',
          name: 'Herramienta general',
          category: InventoryCategory.tool,
          quantity: 1,
          unit: 'juego',
          notes: 'Picos, palas, machetes',
        ),
      ],
    );

    final casaCorral1 = LocationEntity(
      uuid: 'casa-corral-1',
      name: 'Corral 1',
      parentUuid: 'prop-casa',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 3,
      waterSource: 'Bebedero compartido',
      terrainType: 'Tierra apisonada',
      status: LocationStatus.inUse,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 1)),
          animals: 2,
          notes: '2 vacas en resguardo',
        ),
      ],
    );

    final casaCorral2 = LocationEntity(
      uuid: 'casa-corral-2',
      name: 'Corral 2',
      parentUuid: 'prop-casa',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 3,
      waterSource: 'Bebedero compartido',
      terrainType: 'Tierra apisonada',
      status: LocationStatus.available,
    );

    final casaBebedero = LocationEntity(
      uuid: 'casa-bebedero',
      name: 'Bebedero Compartido',
      parentUuid: 'prop-casa',
      type: LocationType.trough,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Toma directa',
      terrainType: 'Cemento',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 1)),
          level: 80,
          type: WaterType.trough,
          notes: 'Lleno, sin fugas',
        ),
      ],
    );

    // ── Milpa children ──────────────────────────────────────────────────────
    final milpaBodega = LocationEntity(
      uuid: 'milpa-bodega',
      name: 'Bodega Heno',
      parentUuid: 'milpa-prop',
      type: LocationType.warehouse,
      surfaceArea: 0,
      capacity: 0,
      waterSource: '',
      terrainType: 'Lamina y block',
      status: LocationStatus.available,
      inventory: [
        InventoryItem(
          uuid: 'item-heno-milpa',
          name: 'Pacas de heno',
          category: InventoryCategory.feed,
          quantity: 80,
          unit: 'paca',
          notes: 'Para becerros y suplemento',
        ),
      ],
    );

    final milpaCorralA = LocationEntity(
      uuid: 'milpa-corral-a',
      name: 'Corral A',
      parentUuid: 'milpa-prop',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 5,
      waterSource: 'Aguada 1',
      terrainType: 'Tierra',
      status: LocationStatus.available,
    );

    final milpaCorralB = LocationEntity(
      uuid: 'milpa-corral-b',
      name: 'Corral B',
      parentUuid: 'milpa-prop',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 5,
      waterSource: 'Aguada 2',
      terrainType: 'Tierra',
      status: LocationStatus.available,
    );

    final milpaCorralBecerros = LocationEntity(
      uuid: 'milpa-corral-becerros',
      name: 'Corral Becerros',
      parentUuid: 'milpa-prop',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 8,
      waterSource: 'Bebedero interno',
      terrainType: 'Tierra con sombra',
      status: LocationStatus.available,
    );

    final milpaCampo = LocationEntity(
      uuid: 'milpa-campo',
      name: 'Campo Cultivado',
      parentUuid: 'milpa-prop',
      type: LocationType.milpa,
      surfaceArea: 4.0,
      capacity: 0,
      waterSource: 'Temporal (lluvia)',
      terrainType: 'Franco arcilloso profundo',
      status: LocationStatus.inPreparation,
      seedings: [
        SeedingRecord(
          date: now.subtract(const Duration(days: 20)),
          crop: 'Maíz criollo',
          surface: 4.0,
          cost: 3200,
        ),
      ],
      irrigations: [
        IrrigationRecord(
          date: now.subtract(const Duration(days: 5)),
          type: 'Temporal natural',
          duration: Duration.zero,
          cost: 0,
        ),
      ],
    );

    final milpaAguada1 = LocationEntity(
      uuid: 'milpa-aguada-1',
      name: 'Aguada 1',
      parentUuid: 'milpa-prop',
      type: LocationType.pond,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Captación pluvial',
      terrainType: 'Arcilla compactada',
      status: LocationStatus.inUse,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 3)),
          level: 65,
          type: WaterType.pond,
          notes: 'Nivel regular, sin animales muertos',
        ),
      ],
    );

    final milpaAguada2 = LocationEntity(
      uuid: 'milpa-aguada-2',
      name: 'Aguada 2',
      parentUuid: 'milpa-prop',
      type: LocationType.pond,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Captación pluvial',
      terrainType: 'Arcilla compactada',
      status: LocationStatus.inUse,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 3)),
          level: 55,
          type: WaterType.pond,
          notes: 'Nivel bajo por temporada seca',
        ),
      ],
    );

    // ── Ejido right children ────────────────────────────────────────────────
    final ejidoCorralPriv = LocationEntity(
      uuid: 'ejido-corral-priv',
      name: 'Corral Privado',
      parentUuid: 'ejido-derecho',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 20,
      waterSource: 'Sistema de agua comunal',
      terrainType: 'Tierra con cerco propio',
      status: LocationStatus.inUse,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 4)),
          animals: 18,
          notes: 'Ganado en agostadero comunal, corral para encierro nocturno',
        ),
      ],
    );

    final ejidoBebedero1 = LocationEntity(
      uuid: 'ejido-bebedero-1',
      name: 'Bebedero Derecho 1',
      parentUuid: 'ejido-derecho',
      type: LocationType.trough,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Red de agua comunal',
      terrainType: 'Compactado con grava',
      status: LocationStatus.inUse,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 3)),
          level: 70,
          type: WaterType.trough,
          notes: 'Abastecimiento estable para encierro nocturno',
        ),
      ],
    );

    // ── Monte ejidal children ───────────────────────────────────────────────
    final montePresa1 = LocationEntity(
      uuid: 'monte-presa-1',
      name: 'Presa 1',
      parentUuid: 'monte-ejidal',
      type: LocationType.dam,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Escurrimiento natural',
      terrainType: 'Arcilla',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 6)),
          level: 72,
          type: WaterType.dam,
          notes: 'Nivel estable',
        ),
      ],
    );

    final montePresa2 = LocationEntity(
      uuid: 'monte-presa-2',
      name: 'Presa 2',
      parentUuid: 'monte-ejidal',
      type: LocationType.dam,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Escurrimiento natural',
      terrainType: 'Arcilla',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 6)),
          level: 60,
          type: WaterType.dam,
          notes: 'Ligero descenso por calor',
        ),
      ],
    );

    final montePresa3 = LocationEntity(
      uuid: 'monte-presa-3',
      name: 'Presa 3',
      parentUuid: 'monte-ejidal',
      type: LocationType.dam,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Escurrimiento natural',
      terrainType: 'Arcilla',
      status: LocationStatus.available,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 10)),
          level: 85,
          type: WaterType.dam,
          notes: 'Nivel alto, reciente lluvia',
        ),
      ],
    );

    final montePresa4 = LocationEntity(
      uuid: 'monte-presa-4',
      name: 'Presa 4',
      parentUuid: 'monte-ejidal',
      type: LocationType.dam,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Escurrimiento natural',
      terrainType: 'Arcilla',
      status: LocationStatus.resting,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 15)),
          level: 30,
          type: WaterType.dam,
          notes: 'Bajo — zona en descanso',
        ),
      ],
    );

    final montePresa5 = LocationEntity(
      uuid: 'monte-presa-5',
      name: 'Presa 5',
      parentUuid: 'monte-ejidal',
      type: LocationType.dam,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Escurrimiento natural',
      terrainType: 'Arcilla',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 4)),
          level: 78,
          type: WaterType.dam,
          notes: 'Uso activo ganado ejidal',
        ),
      ],
    );

    final monteRepreso1 = LocationEntity(
      uuid: 'monte-represo-1',
      name: 'Represo 1',
      parentUuid: 'monte-ejidal',
      type: LocationType.reservoir,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Captación de escurrimiento',
      terrainType: 'Arcilla compactada',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 5)),
          level: 68,
          type: WaterType.dam,
          notes: 'Represo comunal operativo',
        ),
      ],
    );

    final monteCorralComunal = LocationEntity(
      uuid: 'monte-corral-comunal',
      name: 'Corral Comunal',
      parentUuid: 'monte-ejidal',
      type: LocationType.corral,
      surfaceArea: 0,
      capacity: 40,
      waterSource: 'Toma desde represo',
      terrainType: 'Tierra con cerco de madera',
      status: LocationStatus.inUse,
      isShared: true,
      visits: [
        VisitRecord(
          date: now.subtract(const Duration(days: 2)),
          animals: 24,
          notes: 'Uso rotativo de productores del ejido',
        ),
      ],
    );

    final monteBebederoComunal = LocationEntity(
      uuid: 'monte-bebedero-comunal',
      name: 'Bebedero Comunal',
      parentUuid: 'monte-ejidal',
      type: LocationType.trough,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Alimentado por represo',
      terrainType: 'Plataforma compactada',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 1)),
          level: 82,
          type: WaterType.trough,
          notes: 'Llenado diario para ganado en monte',
        ),
      ],
    );

    final monteManantial1 = LocationEntity(
      uuid: 'monte-manantial-1',
      name: 'Manantial 1',
      parentUuid: 'monte-ejidal',
      type: LocationType.spring,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Manantial natural perenne',
      terrainType: 'Rocoso',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 2)),
          level: 90,
          type: WaterType.spring,
          notes: 'Flujo constante todo el año',
        ),
      ],
    );

    final monteManantial2 = LocationEntity(
      uuid: 'monte-manantial-2',
      name: 'Manantial 2',
      parentUuid: 'monte-ejidal',
      type: LocationType.spring,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Manantial natural',
      terrainType: 'Rocoso con vegetación',
      status: LocationStatus.inUse,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 8)),
          level: 75,
          type: WaterType.spring,
          notes: 'Flujo moderado',
        ),
      ],
    );

    final monteManantial3 = LocationEntity(
      uuid: 'monte-manantial-3',
      name: 'Manantial 3',
      parentUuid: 'monte-ejidal',
      type: LocationType.spring,
      surfaceArea: 0,
      capacity: 0,
      waterSource: 'Manantial estacional',
      terrainType: 'Rocoso',
      status: LocationStatus.available,
      isShared: true,
      waters: [
        WaterRecord(
          date: now.subtract(const Duration(days: 20)),
          level: 40,
          type: WaterType.spring,
          notes: 'Solo activo en temporada de lluvias',
        ),
      ],
    );

    final seeds = [
      propCasa,
      milpaProp,
      ejidoDerecho,
      monteEjidal,
      casaHouse,
      casaBodega,
      casaCorral1,
      casaCorral2,
      casaBebedero,
      milpaBodega,
      milpaCorralA,
      milpaCorralB,
      milpaCorralBecerros,
      milpaCampo,
      milpaAguada1,
      milpaAguada2,
      ejidoCorralPriv,
      ejidoBebedero1,
      montePresa1,
      montePresa2,
      montePresa3,
      montePresa4,
      montePresa5,
      monteRepreso1,
      monteCorralComunal,
      monteBebederoComunal,
      monteManantial1,
      monteManantial2,
      monteManantial3,
    ];

    await isar.writeTxn(() async {
      await isar.isarLocations.putAll(seeds.map((e) => e.toIsar()).toList());
    });

    LoggerService.i(
      'Seeded ubicaciones: ${seeds.length} locations',
      tag: 'IsarLocation',
    );
  }

  /// Fixes legacy seed data where 'ejido-derecho' was stored as a top-level
  /// root before the parent relationship to 'monte-ejidal' was introduced.
  /// Safe to call on every startup — no-ops when the data is already correct.
  Future<void> _migrateEjidoParentIfNeeded(Isar isar) async {
    final ejido = await isar.isarLocations
        .where()
        .uuidEqualTo('ejido-derecho')
        .findFirst();
    if (ejido == null || ejido.parentUuid != null) return;

    final monte = await isar.isarLocations
        .where()
        .uuidEqualTo('monte-ejidal')
        .findFirst();
    if (monte == null) return;

    ejido.parentUuid = 'monte-ejidal';
    await isar.writeTxn(() async {
      await isar.isarLocations.put(ejido);
    });
    LoggerService.i(
      'Migración: ejido-derecho reasignado como hijo de monte-ejidal',
      tag: 'IsarLocation',
    );
  }
}
