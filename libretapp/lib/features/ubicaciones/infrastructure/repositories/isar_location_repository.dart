/// features \u203a ubicaciones \u203a infrastructure \u203a repositories \u203a isar_location_repository \u2014 Isar implementation of LocationRepository.
library;

import 'package:libretapp/core/utils/numeric_validation.dart';


import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';

import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

class IsarLocationRepository implements LocationRepository {
  IsarLocationRepository(this._database);

  final IsarDatabase _database;

  @override
  Stream<List<LocationEntity>> watchAll() => _watchAll().asBroadcastStream();

  Stream<List<LocationEntity>> _watchAll() async* {
    final isar = await _database.initialize();
    yield* isar.isarLocations
        .filter()
        .archivedAtIsNull()
        .watch(fireImmediately: true)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<List<LocationEntity>> getAll() async {
    final isar = await _database.initialize();
    final items = await isar.isarLocations
        .filter()
        .archivedAtIsNull()
        .findAll();
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
    requireFiniteNumbers(location);
    final isar = await _database.initialize();
    await isar.writeTxn(() async {
      final existing = await isar.isarLocations
          .where()
          .uuidEqualTo(location.uuid)
          .findFirst();
      final now = DateTime.now().toUtc();
      final model = location
          .copyWith(
            createdAt: location.createdAt ?? existing?.createdAt ?? now,
            updatedAt: now,
          )
          .toIsar(existing?.id);
      await isar.isarLocations.put(model);
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
      if (location == null) return;
      location.archivedAt = DateTime.now().toUtc();
      location.updatedAt = DateTime.now().toUtc();
      location.status = LocationStatus.closed.name;
      requireFiniteNumbers(location.toEntity());
      await isar.isarLocations.put(location);
      LoggerService.i('Ubicacion archivada: $uuid', tag: 'IsarLocation');
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
  Future<void> addCost(String uuid, LocationCostRecord record) async {
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
      final index = location.crops.indexWhere((c) => c.uuid == cropUuid);
      if (index == -1) {
        throw StateError('Cultivo $cropUuid no encontrado');
      }
      location.crops[index].status = CropStatus.archived.name;
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
      if (record.isFinal) {
        crop.status = CropStatus.harvested.name;
      }
    });
  }

  @override
  Future<void> addMaintenance(String uuid, MaintenanceRecord record) async {
    await _modify(uuid, (location) {
      location.maintenances.add(IsarMaintenanceRecord.fromEntity(record));
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
      location.updatedAt = DateTime.now().toUtc();
      requireFiniteNumbers(location.toEntity());
      await isar.isarLocations.put(location);
    });
  }

}
