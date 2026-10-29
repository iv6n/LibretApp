import 'package:libretapp/core/di/web/farm_record_access.dart';
import 'package:libretapp/core/di/web/location_json_codec.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class WebLocationRepository implements LocationRepository {
  WebLocationRepository(this.access);
  final FarmRecordAccess access;
  static const _kind = 'location';

  @override
  Stream<List<LocationEntity>> watchAll() => access
      .watch(_kind)
      .map(
        (rows) => rows
            .map((r) => LocationJsonCodec.decode(r.payload))
            .where((l) => l.archivedAt == null)
            .toList(),
      );
  @override
  Future<List<LocationEntity>> getAll() async => (await access.list(_kind))
      .map((r) => LocationJsonCodec.decode(r.payload))
      .where((l) => l.archivedAt == null)
      .toList();
  @override
  Future<LocationEntity?> getByUuid(String uuid) async {
    final row = await access.get(_kind, uuid);
    return row == null ? null : LocationJsonCodec.decode(row.payload);
  }

  @override
  Future<void> upsert(LocationEntity location) => access.transaction(() async {
    await access.requireWrite();
    if (location.name.trim().isEmpty)
      throw ArgumentError('Indica el nombre de la ubicación.');
    final previous = await getByUuid(location.uuid);
    final now = DateTime.now().toUtc();
    final saved = location.copyWith(
      createdAt: location.createdAt ?? previous?.createdAt ?? now,
      updatedAt: now,
    );
    await access.put(
      _kind,
      saved.uuid,
      LocationJsonCodec.encode(saved),
      createdAt: saved.createdAt,
    );
  });
  @override
  Future<void> deleteByUuid(String uuid) => _modify(
    uuid,
    (l) => l.copyWith(
      archivedAt: DateTime.now().toUtc(),
      status: LocationStatus.closed,
    ),
  );

  Future<void> _modify(
    String uuid,
    LocationEntity Function(LocationEntity) change,
  ) => access.transaction(() async {
    final location = await getByUuid(uuid);
    if (location == null) throw StateError('Ubicación no encontrada.');
    await upsert(change(location));
  });

  @override
  Future<void> addVisit(String uuid, VisitRecord record) =>
      _modify(uuid, (l) => l.copyWith(visits: [...l.visits, record]));
  @override
  Future<void> addWater(String uuid, WaterRecord record) =>
      _modify(uuid, (l) => l.copyWith(waters: [...l.waters, record]));
  @override
  Future<void> addSalt(String uuid, SaltRecord record) =>
      _modify(uuid, (l) => l.copyWith(salts: [...l.salts, record]));
  @override
  Future<void> addShade(String uuid, ShadeRecord record) =>
      _modify(uuid, (l) => l.copyWith(shades: [...l.shades, record]));
  @override
  Future<void> addPasture(String uuid, PastureRecord record) =>
      _modify(uuid, (l) => l.copyWith(pastures: [...l.pastures, record]));
  @override
  Future<void> addSeeding(String uuid, SeedingRecord record) =>
      _modify(uuid, (l) => l.copyWith(seedings: [...l.seedings, record]));
  @override
  Future<void> addIrrigation(String uuid, IrrigationRecord record) =>
      _modify(uuid, (l) => l.copyWith(irrigations: [...l.irrigations, record]));
  @override
  Future<void> addRain(String uuid, RainRecord record) =>
      _modify(uuid, (l) => l.copyWith(rains: [...l.rains, record]));
  @override
  Future<void> addCost(String uuid, LocationCostRecord record) =>
      _modify(uuid, (l) => l.copyWith(costs: [...l.costs, record]));
  @override
  Future<void> addMaintenance(String uuid, MaintenanceRecord record) => _modify(
    uuid,
    (l) => l.copyWith(maintenances: [...l.maintenances, record]),
  );

  @override
  Future<void> addCrop(String uuid, CropRecord crop) => _modify(uuid, (l) {
    if (l.crops.any((c) => c.uuid == crop.uuid))
      throw ArgumentError('El cultivo ya existe.');
    return l.copyWith(crops: [...l.crops, crop]);
  });
  @override
  Future<void> updateCrop(String uuid, CropRecord crop) =>
      _modifyCrop(uuid, crop.uuid, (_) => crop);
  @override
  Future<void> deleteCrop(String uuid, String cropUuid) => _modifyCrop(
    uuid,
    cropUuid,
    (c) => c.copyWith(status: CropStatus.archived),
  );
  Future<void> _modifyCrop(
    String uuid,
    String cropUuid,
    CropRecord Function(CropRecord) change,
  ) => _modify(uuid, (l) {
    if (!l.crops.any((c) => c.uuid == cropUuid))
      throw StateError('Cultivo no encontrado.');
    return l.copyWith(
      crops: l.crops.map((c) => c.uuid == cropUuid ? change(c) : c).toList(),
    );
  });
  @override
  Future<void> addHarvest(String uuid, String cropUuid, HarvestRecord record) =>
      _modifyCrop(
        uuid,
        cropUuid,
        (c) => c.copyWith(
          harvests: [...c.harvests, record],
          status: record.isFinal ? CropStatus.harvested : c.status,
        ),
      );
  @override
  Future<void> addCropWatering(
    String uuid,
    String cropUuid,
    CropWateringRecord record,
  ) => _modifyCrop(
    uuid,
    cropUuid,
    (c) => c.copyWith(
      waterings: [...c.waterings, record],
      lastWateredDate: record.date,
    ),
  );
  @override
  Future<void> addCropHealth(
    String uuid,
    String cropUuid,
    CropHealthRecord record,
  ) => _modifyCrop(
    uuid,
    cropUuid,
    (c) => c.copyWith(healthRecords: [...c.healthRecords, record]),
  );
  @override
  Future<void> addCropTask(String uuid, String cropUuid, CropTask task) =>
      _modifyCrop(uuid, cropUuid, (c) => c.copyWith(tasks: [...c.tasks, task]));
  @override
  Future<void> completeCropTask(
    String uuid,
    String cropUuid,
    String taskUuid,
  ) => _modifyCrop(uuid, cropUuid, (c) {
    if (!c.tasks.any((t) => t.uuid == taskUuid))
      throw StateError('Tarea no encontrada.');
    return c.copyWith(
      tasks: c.tasks
          .map((t) => t.uuid == taskUuid ? t.copyWith(completed: true) : t)
          .toList(),
    );
  });

  @override
  Future<void> addInventoryItem(String uuid, InventoryItem item) =>
      _modify(uuid, (l) {
        if (l.inventory.any((i) => i.uuid == item.uuid))
          throw ArgumentError('El artículo ya existe.');
        return l.copyWith(inventory: [...l.inventory, item]);
      });
  @override
  Future<void> updateInventoryItem(String uuid, InventoryItem item) =>
      _modify(uuid, (l) {
        if (!l.inventory.any((i) => i.uuid == item.uuid))
          throw StateError('Artículo no encontrado.');
        return l.copyWith(
          inventory: l.inventory
              .map((i) => i.uuid == item.uuid ? item : i)
              .toList(),
        );
      });
  @override
  Future<void> removeInventoryItem(String uuid, String itemUuid) => _modify(
    uuid,
    (l) => l.copyWith(
      inventory: l.inventory.where((i) => i.uuid != itemUuid).toList(),
    ),
  );
}
