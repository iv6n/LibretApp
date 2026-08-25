/// features \u203a directorio \u203a animales \u203a infrastructure \u203a animal_repository_isar \u2014 Isar implementation of AnimalRepository.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_taxonomy.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_care.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_agenda_registration.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_entry.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_session.dart';

class AnimalRepositoryIsar implements AnimalRepository {
  AnimalRepositoryIsar(this._database, this._prefs, this._remoteDataSource);

  static const _logTag = 'AnimalRepositoryIsar';
  final IsarDatabase _database;
  final SharedPrefsService _prefs;
  final AnimalRemoteDataSource _remoteDataSource;
  Future<void>? _activityBackfillFuture;

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
    await _ensureActivityBackfill();
    final isar = await _isar;
    yield* isar.isarAnimals.where().watch(fireImmediately: true).asyncMap((
      records,
    ) async {
      final animals = records
          .where((record) => record.status == AnimalStatus.active.name)
          .toList();
      return _normalizeRecords(animals);
    });
  }

  @override
  Future<List<AnimalEntity>> getAll() => _activeNormalized();

  Future<List<AnimalEntity>> _activeNormalized({bool sorted = true}) async {
    await _ensureActivityBackfill();
    final isar = await _isar;
    final records = await isar.isarAnimals.where().findAll();
    final active = records
        .where((record) => record.status == AnimalStatus.active.name)
        .toList();
    return _normalizeRecords(active, sorted: sorted);
  }

  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async {
    await _ensureActivityBackfill();
    final isar = await _isar;
    final records = await isar.isarAnimals.where().findAll();
    return _normalizeRecords(records);
  }

  /// Kept as the name the backup path already calls.
  Future<List<AnimalEntity>> getAllIncludingArchived() =>
      getAllIncludingInactive();

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async {
    final isar = await _isar;
    final record = await isar.isarAnimals
        .where()
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
        .where()
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
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .where()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..remoteId = remoteId
          ..synced = true
          ..syncDate = DateTime.now();
        await isar.isarAnimals.put(record);
      }
    });
  }

  @override
  Future<void> markAsUnsynchronized(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .where()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..synced = false
          ..syncDate = null;
        await isar.isarAnimals.put(record);
      }
    });
  }

  @override
  Future<void> delete(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .where()
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
  Future<void> purge(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarAnimals.where().uuidEqualTo(uuid).deleteAll();
    });
    LoggerService.w('Animal eliminado definitivamente $uuid', tag: _logTag);
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
  Future<Map<LifeStage, int>> getActiveStageCounts() async {
    final counts = <LifeStage, int>{};
    for (final animal in await _activeNormalized(sorted: false)) {
      counts.update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  @override
  Future<Map<Species, Map<LifeStage, int>>> getActiveTaxonomyCounts() async {
    final counts = <Species, Map<LifeStage, int>>{};
    for (final animal in await _activeNormalized(sorted: false)) {
      counts
          .putIfAbsent(animal.species, () => <LifeStage, int>{})
          .update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
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
    final animals = await getAll();
    return List.unmodifiable(animals.skip(offset).take(limit));
  }

  /// Normalizes [records] into entities, persisting any derived field that
  /// drifted (age, category, life stage).
  ///
  /// [sorted] is off for the callers that only tally the herd: the directory
  /// order costs a full sort of every animal, and a count does not depend on
  /// it.
  Future<List<AnimalEntity>> _normalizeRecords(
    List<IsarAnimal> records, {
    bool sorted = true,
  }) async {
    final normalized = <AnimalEntity>[];
    final changed = <IsarAnimal>[];

    for (final record in records) {
      final current = record.toEntity();
      final lifecycle = AnimalLifecycleCalculator.calculate(
        birthDate: current.birthDate,
        species: current.species,
        sex: current.sex,
        category: current.category,
        currentLifeStage: current.lifeStage,
      );
      final neutered =
          current.reproductiveStatus == ReproductiveStatus.neutered ||
          current.category == Category.steer ||
          current.category == Category.oxen;
      final category = current.species == Species.cattle
          ? AnimalTaxonomy.defaultCategory(
              species: current.species,
              sex: current.sex,
              ageMonths: lifecycle.ageMonths,
              neutered: neutered,
            )
          : current.category;
      final stage = AnimalTaxonomy.resolveLifeStage(
        species: current.species,
        sex: current.sex,
        ageMonths: lifecycle.ageMonths,
        category: category,
        fallback: lifecycle.lifeStage,
      );
      final next = current.copyWith(
        ageMonths: lifecycle.ageMonths,
        category: category,
        lifeStage: stage,
      );
      normalized.add(next);
      if (next.ageMonths != current.ageMonths ||
          next.category != current.category ||
          next.lifeStage != current.lifeStage) {
        changed.add(next.toIsar()..id = record.id);
      }
    }

    if (changed.isNotEmpty) {
      final isar = await _isar;
      await isar.writeTxn(() => isar.isarAnimals.putAll(changed));
    }

    if (sorted) _sortByActivity(normalized);
    return List.unmodifiable(normalized);
  }

  @override
  Future<AnimalEntity> updateDerivedLifecycle(AnimalEntity animal) async {
    final isar = await _isar;
    final existing = await isar.isarAnimals
        .where()
        .uuidEqualTo(animal.uuid)
        .findFirst();
    if (existing == null) return animal;

    final model = animal.toIsar()..id = existing.id;
    await isar.writeTxn(() => isar.isarAnimals.put(model));
    return animal;
  }

  Future<void> _ensureActivityBackfill() async {
    if (_prefs.getBool(PrefsKeys.animalsActivityBackfillV1) == true) return;
    final running = _activityBackfillFuture;
    if (running != null) {
      await running;
      return;
    }

    final future = _backfillActivity();
    _activityBackfillFuture = future;
    try {
      await future;
    } finally {
      if (identical(_activityBackfillFuture, future)) {
        _activityBackfillFuture = null;
      }
    }
  }

  Future<void> _backfillActivity() async {
    final isar = await _isar;
    final latest = <String, DateTime>{};

    void add(String? animalUuid, DateTime? value) {
      if (animalUuid == null || animalUuid.trim().isEmpty || value == null) {
        return;
      }
      final current = latest[animalUuid];
      if (current == null || value.isAfter(current)) {
        latest[animalUuid] = value;
      }
    }

    for (final record in await isar.isarHealthRecords.where().findAll()) {
      add(record.animalUuid, record.updatedAt ?? record.date);
    }
    for (final record in await isar.isarWeightRecords.where().findAll()) {
      add(record.animalUuid, record.updatedAt ?? record.date);
    }
    for (final record in await isar.isarReproductionRecords.where().findAll()) {
      add(record.animalUuid, record.updatedAt ?? record.serviceDate);
    }
    for (final record in await isar.isarMovementRecords.where().findAll()) {
      add(record.animalUuid, record.updatedAt ?? record.date);
    }
    for (final record in await isar.isarProductionRecords.where().findAll()) {
      add(record.animalUuid, record.date);
    }
    for (final record in await isar.isarCommercialRecords.where().findAll()) {
      add(record.animalUuid, record.date);
    }
    for (final record in await isar.isarCostRecords.where().findAll()) {
      add(record.animalUuid, record.date);
    }
    for (final record in await isar.isarCareRecords.where().findAll()) {
      add(record.animalUuid, record.performedAt);
    }
    for (final record in await isar.isarAgendaRegistrations.where().findAll()) {
      add(record.animalId, record.updatedAt);
    }

    final sessions = await isar.isarMilkingSessions.where().findAll();
    final sessionsByUuid = {
      for (final session in sessions) session.uuid: session,
    };
    for (final entry in await isar.isarMilkingEntrys.where().findAll()) {
      final session = sessionsByUuid[entry.sessionUuid];
      if (session?.status != 'completed') continue;
      add(entry.animalUuid, session!.updatedAt);
      add(entry.animalUuid, entry.updatedAt);
    }

    final changed = <IsarAnimal>[];
    for (final animal in await isar.isarAnimals.where().findAll()) {
      final activity = latest[animal.uuid];
      if (activity == null || !activity.isAfter(animal.lastUpdateDate)) {
        continue;
      }
      animal.lastUpdateDate = activity;
      changed.add(animal);
    }
    if (changed.isNotEmpty) {
      await isar.writeTxn(() => isar.isarAnimals.putAll(changed));
    }
    await _prefs.setBool(PrefsKeys.animalsActivityBackfillV1, true);
  }

  /// Orders the directory: most recent activity first, then youngest, then by
  /// ear tag.
  ///
  /// The per-animal keys are built once instead of inside the comparator. The
  /// comparator ran O(n log n) times and each call read the clock twice and
  /// rebuilt two lower-cased ear tags, so at herd scale the key work cost more
  /// than the sort. Reading the clock once also makes the ordering consistent,
  /// which it was not while `now` could tick between two comparisons.
  static void _sortByActivity(List<AnimalEntity> animals) {
    if (animals.length < 2) return;

    final now = DateTime.now();
    final keyed = List<_ActivitySortKey>.generate(
      animals.length,
      (index) => _ActivitySortKey(animals[index], now),
      growable: false,
    )..sort(_ActivitySortKey.compare);

    for (var index = 0; index < keyed.length; index++) {
      animals[index] = keyed[index].animal;
    }
  }
}

/// An animal plus the derived fields [AnimalRepositoryIsar._sortByActivity]
/// orders on, computed once per animal rather than once per comparison.
class _ActivitySortKey {
  _ActivitySortKey(this.animal, DateTime now)
    : ageMonths = AnimalLifecycleCalculator.monthsBetween(
        animal.birthDate,
        now,
      ),
      earTag = animal.earTagNumber.trim().toLowerCase();

  final AnimalEntity animal;
  final int ageMonths;
  final String earTag;

  static int compare(_ActivitySortKey a, _ActivitySortKey b) {
    final activity = b.animal.lastUpdateDate.compareTo(a.animal.lastUpdateDate);
    if (activity != 0) return activity;

    final age = a.ageMonths.compareTo(b.ageMonths);
    if (age != 0) return age;

    final earTag = a.earTag.compareTo(b.earTag);
    if (earTag != 0) return earTag;

    return a.animal.uuid.compareTo(b.animal.uuid);
  }
}
