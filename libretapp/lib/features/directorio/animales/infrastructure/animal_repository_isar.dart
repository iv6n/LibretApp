/// features \u203a directorio \u203a animales \u203a infrastructure \u203a animal_repository_isar \u2014 Isar implementation of AnimalRepository.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';

class AnimalRepositoryIsar implements AnimalRepository {
  AnimalRepositoryIsar(this._database, this._prefs, this._remoteDataSource);

  static const _logTag = 'AnimalRepositoryIsar';
  final IsarDatabase _database;
  final SharedPrefsService _prefs;
  final AnimalRemoteDataSource _remoteDataSource;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<bool> refreshFromRemote({bool force = false}) async {
    final remote = await _remoteDataSource.fetchAnimals();
    final lastHash = _prefs.getString(PrefsKeys.animalsHash);
    final shouldUpdate = force || lastHash != remote.hash;

    await _prefs.setString(PrefsKeys.animalsHash, remote.hash);
    await _prefs.setDateTime(PrefsKeys.animalsLastSync, remote.lastUpdated);

    if (!shouldUpdate) {
      LoggerService.i('Animales sin cambios desde remoto', tag: _logTag);
      return false;
    }

    final isar = await _isar;
    final existing = await isar.isarAnimals.where().findAll();
    final idsByUuid = {for (final record in existing) record.uuid: record.id};

    final models = remote.animals
        .map((dto) {
          final entity = dto.toEntity();
          final model = entity.toIsar();
          final existingId = idsByUuid[dto.uuid];
          if (existingId != null) {
            model.id = existingId;
          }
          return model;
        })
        .toList(growable: false);

    await isar.writeTxn(() async {
      await isar.isarAnimals.putAll(models);
    });

    LoggerService.i(
      'Animales actualizados desde remoto (${models.length})',
      tag: _logTag,
    );
    return true;
  }

  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    final isar = await _isar;
    yield* isar.isarAnimals
        .where()
        .watch(fireImmediately: true)
        .map(
          (records) => records
              .map((e) => e.toEntity())
              .where((animal) => animal.status.isInActiveHerd)
              .toList(growable: false),
        );
  }

  @override
  Future<List<AnimalEntity>> getAll() async {
    final isar = await _isar;
    final records = await isar.isarAnimals.where().findAll();
    return records
        .map((e) => e.toEntity())
        .where((animal) => animal.status.isInActiveHerd)
        .toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async {
    final isar = await _isar;
    final records = await isar.isarAnimals.where().findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  /// Kept as the name the backup path already calls.
  Future<List<AnimalEntity>> getAllIncludingArchived() =>
      getAllIncludingInactive();

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async {
    final isar = await _isar;
    final record = await isar.isarAnimals
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
    return record?.toEntity();
  }

  @override
  Future<List<AnimalEntity>> getBySpecies(String speciesName) async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .speciesEqualTo(speciesName)
        .findAll();
    return records
        .map((e) => e.toEntity())
        .where((animal) => animal.status.isInActiveHerd)
        .toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getByPaddock(String paddockId) async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .currentLocationIdEqualTo(paddockId)
        .findAll();
    return records
        .map((e) => e.toEntity())
        .where((animal) => animal.status.isInActiveHerd)
        .toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getByBatchUuid(String batchUuid) async {
    final all = await getAll();
    return all.where((a) => a.batchUuid == batchUuid).toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getByParentUuid(String parentUuid) async {
    final isar = await _isar;

    // Two index-backed lookups instead of one filter scan: `sireUuid` and
    // `damUuid` are separate indexes, so an OR across them cannot be a single
    // where clause.
    final bySire = await isar.isarAnimals
        .where()
        .sireUuidEqualTo(parentUuid)
        .findAll();
    final byDam = await isar.isarAnimals
        .where()
        .damUuidEqualTo(parentUuid)
        .findAll();

    // An animal can appear in both lists only through corrupt data (same
    // parent recorded as sire and dam), but de-duplicate anyway.
    final merged = <String, AnimalEntity>{};
    for (final record in [...bySire, ...byDam]) {
      final entity = record.toEntity();
      merged[entity.uuid] = entity;
    }

    // Archived offspring are kept on purpose: a calf that was sold or died is
    // still part of its dam's production history, which is the whole point of
    // looking at her progeny.
    final offspring = merged.values.toList()
      ..sort((a, b) => b.birthDate.compareTo(a.birthDate));
    return List<AnimalEntity>.unmodifiable(offspring);
  }

  @override
  Future<List<AnimalEntity>> getAnimalsRequiringAttention() async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .anyOf([
          RiskLevel.high.name,
          RiskLevel.critical.name,
        ], (q, level) => q.riskLevelEqualTo(level))
        .or()
        .requiresAttentionEqualTo(true)
        .or()
        .underObservationEqualTo(true)
        .or()
        .healthStatusEqualTo(HealthStatus.poor.name)
        .or()
        .healthStatusEqualTo(HealthStatus.critical.name)
        .findAll();
    return records
        .map((e) => e.toEntity())
        .where((animal) => animal.status.isInActiveHerd)
        .toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getUnsynchronized() async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .syncedEqualTo(false)
        .findAll();
    return records
        .map((e) => e.toEntity())
        .where((animal) => animal.status.isInActiveHerd)
        .toList(growable: false);
  }

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    final isar = await _isar;
    final now = DateTime.now();
    final entity = animal.copyWith(
      creationDate: animal.creationDate,
      lastUpdateDate: now,
      synced: false,
    );

    final model = entity.toIsar();
    await isar.writeTxn(() async {
      await isar.isarAnimals.put(model);
    });
    LoggerService.i('Animal guardado ${entity.uuid}', tag: _logTag);
    return entity;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    final isar = await _isar;
    final now = DateTime.now();
    final updated = animal.copyWith(lastUpdateDate: now, synced: false);
    final existing = await isar.isarAnimals
        .filter()
        .uuidEqualTo(animal.uuid)
        .findFirst();
    final model = updated.toIsar();
    if (existing != null) {
      model.id = existing.id;
    }
    await isar.writeTxn(() async {
      await isar.isarAnimals.put(model);
    });
    LoggerService.i('Animal actualizado ${updated.uuid}', tag: _logTag);
    return updated;
  }

  @override
  Future<void> markAsSynced(String uuid, String remoteId) async {
    final isar = await _isar;
    final now = DateTime.now();
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..remoteId = remoteId
          ..synced = true
          ..syncDate = now
          ..lastUpdateDate = now;
        await isar.isarAnimals.put(record);
      }
    });
  }

  @override
  Future<void> markAsUnsynchronized(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..synced = false
          ..syncDate = null
          ..lastUpdateDate = DateTime.now();
        await isar.isarAnimals.put(record);
      }
    });
  }

  @override
  Future<void> delete(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..status = AnimalStatus.archived.name
          ..synced = false
          ..lastUpdateDate = DateTime.now();
        await isar.isarAnimals.put(record);
      }
    });
    LoggerService.w('Animal archivado $uuid', tag: _logTag);
  }

  @override
  Future<void> clearAll() async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.isarAnimals.clear());
    LoggerService.w('Colección animales limpiada', tag: _logTag);
  }

  @override
  Future<int> count() async {
    final isar = await _isar;
    return isar.isarAnimals
        .filter()
        .statusEqualTo(AnimalStatus.active.name)
        .count();
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final isar = await _isar;
    final activeName = AnimalStatus.active.name;

    // These counts feed the dashboard, so they have to mean "the herd you
    // manage". A raw collection count included archived animals — the ones
    // already deleted from the directory — and later sold and dead ones too.
    final total = await isar.isarAnimals
        .filter()
        .statusEqualTo(activeName)
        .count();
    final unsynced = await isar.isarAnimals
        .filter()
        .statusEqualTo(activeName)
        .and()
        .syncedEqualTo(false)
        .count();
    // The OR pair needs its own group, or the status condition binds to just
    // the first branch and animals that left the herd leak back in.
    final attention = await isar.isarAnimals
        .filter()
        .statusEqualTo(activeName)
        .and()
        .group(
          (q) => q
              .requiresAttentionEqualTo(true)
              .or()
              .underObservationEqualTo(true),
        )
        .count();

    return {'total': total, 'unsynced': unsynced, 'attention': attention};
  }

  @override
  Stream<void> watchChanges() async* {
    final isar = await _isar;
    yield* isar.isarAnimals.watchLazy(fireImmediately: false);
  }

  @override
  Future<List<AnimalEntity>> getPage({
    required int offset,
    required int limit,
  }) async {
    final isar = await _isar;
    final records = await isar.isarAnimals.where().findAll();
    return records
        .map((record) => record.toEntity())
        .where((animal) => animal.status.isInActiveHerd)
        .skip(offset)
        .take(limit)
        .toList(growable: false);
  }

}
