/// Isar implementation of [CultivationRepository].
library;
import 'package:libretapp/core/utils/numeric_validation.dart';

import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/isar_cultivation.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';

class CultivationRepositoryIsar implements CultivationRepository {
  CultivationRepositoryIsar(this._database);

  final IsarDatabase _database;

  IsarCollection<IsarCultivation> get _collection =>
      _database.isar.isarCultivations;

  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) {
    return _watchAll(includeArchived: includeArchived).asBroadcastStream();
  }

  Stream<List<CultivationEntity>> _watchAll({
    required bool includeArchived,
  }) {
    return _collection
        .where()
        .watch(fireImmediately: true)
        .map(
          (records) => _sorted(
            records
                .map((record) => record.toEntity())
                .where(
                  (entity) =>
                      includeArchived || entity.status != CropStatus.archived,
                )
                .toList(),
          ),
        );
  }

  @override
  Stream<List<CultivationEntity>> watchByLocation(
    String locationUuid, {
    bool includeArchived = false,
  }) {
    return watchAll(includeArchived: includeArchived).map(
      (items) => items
          .where((item) => item.locationUuid == locationUuid)
          .toList(growable: false),
    );
  }

  @override
  Future<List<CultivationEntity>> getAll({bool includeArchived = false}) async {
    final records = await _collection.where().findAll();
    return _sorted(
      records
          .map((record) => record.toEntity())
          .where(
            (entity) => includeArchived || entity.status != CropStatus.archived,
          )
          .toList(),
    );
  }

  @override
  Future<CultivationEntity?> getByUuid(String uuid) async {
    final record = await _collection.filter().uuidEqualTo(uuid).findFirst();
    return record?.toEntity();
  }

  @override
  Future<void> upsert(CultivationEntity cultivation) async {
    requireFiniteNumbers(cultivation);
    final current = await _collection
        .filter()
        .uuidEqualTo(cultivation.uuid)
        .findFirst();
    final stored = IsarCultivation.fromEntity(
      cultivation.copyWith(updatedAt: DateTime.now()),
    );
    if (current != null) stored.id = current.id;
    await _database.isar.writeTxn(() => _collection.put(stored));
  }

  @override
  Future<void> archive(String uuid) => _mutate(
    uuid,
    (entity) =>
        entity.copyWith(status: CropStatus.archived, updatedAt: DateTime.now()),
  );

  @override
  Future<void> purge(String uuid) async {
    final current = await _collection.filter().uuidEqualTo(uuid).findFirst();
    if (current == null) return;
    await _database.isar.writeTxn(() => _collection.delete(current.id));
  }

  @override
  Future<void> addHarvest(String uuid, HarvestRecord record) => _mutate(
    uuid,
    (entity) => entity.copyWith(
      harvests: [...entity.harvests, record],
      status: record.isFinal ? CropStatus.harvested : entity.status,
      growthStage: record.isFinal
          ? CropGrowthStage.harvested
          : entity.growthStage,
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Future<void> addWatering(String uuid, CropWateringRecord record) => _mutate(
    uuid,
    (entity) => entity.copyWith(
      waterings: [...entity.waterings, record],
      lastWateredDate: record.date,
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Future<void> addHealth(String uuid, CropHealthRecord record) => _mutate(
    uuid,
    (entity) => entity.copyWith(
      healthRecords: [...entity.healthRecords, record],
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Future<void> addTask(String uuid, CropTask task) => _mutate(
    uuid,
    (entity) => entity.copyWith(
      tasks: [...entity.tasks, task],
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Future<void> completeTask(String uuid, String taskUuid) => _mutate(
    uuid,
    (entity) => entity.copyWith(
      tasks: entity.tasks
          .map(
            (task) =>
                task.uuid == taskUuid ? task.copyWith(completed: true) : task,
          )
          .toList(growable: false),
      updatedAt: DateTime.now(),
    ),
  );

  Future<void> _mutate(
    String uuid,
    CultivationEntity Function(CultivationEntity current) update,
  ) async {
    final current = await getByUuid(uuid);
    if (current == null) throw StateError('Cultivo $uuid no encontrado');
    await upsert(update(current));
  }

  List<CultivationEntity> _sorted(List<CultivationEntity> items) {
    items.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return List<CultivationEntity>.unmodifiable(items);
  }
}
