/// Small browser repositories used while legacy Isar screens are migrated to
/// the shared web storage contract. They keep the web build functional and
/// prevent native database classes from leaking into the browser bundle.
library;

export 'web/web_lotes_repository.dart';
export 'web/web_location_repository.dart';
export 'web/web_animal_record_repositories.dart';

import 'dart:async';

import 'package:libretapp/features/agenda/data/agenda_registration_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/rfid/domain/rfid_models.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';

class WebAnimalRepository
    implements AnimalRepository, RegisteredAnimalSpeciesReader {
  WebAnimalRepository(this._store, this._context);

  static const _kind = 'animal';
  final FeatureRecordStore _store;
  final FarmContextRepository _context;
  final _changes = StreamController<void>.broadcast();

  Future<String> get _farmId async =>
      (await _context.current())?.farm.uuid ?? 'default-farm';

  Future<List<AnimalEntity>> _read({bool includeDeleted = false}) async {
    final farmId = await _farmId;
    final rows = await _store.list(
      farmId,
      _kind,
      includeDeleted: includeDeleted,
    );
    return rows
        .map((row) => AnimalDto.fromJson(row.payload).toEntity())
        .toList(growable: false);
  }

  Future<AnimalEntity?> _readOne(String uuid) async {
    final row = await _store.get(await _farmId, uuid);
    if (row == null || row.kind != _kind || row.deletedAt != null) return null;
    return AnimalDto.fromJson(row.payload).toEntity();
  }

  Future<AnimalEntity> _write(
    AnimalEntity animal, {
    bool markUnsynced = true,
  }) async {
    final farmId = await _farmId;
    final current = await _store.get(farmId, animal.uuid);
    final now = DateTime.now().toUtc();
    final saved = animal.copyWith(
      lastUpdateDate: now,
      synced: markUnsynced ? false : animal.synced,
    );
    await _store.put(
      FeatureRecord(
        uuid: saved.uuid,
        farmId: farmId,
        kind: _kind,
        payload: AnimalDto.fromEntity(saved).toJson(),
        createdAt: current?.createdAt ?? saved.creationDate,
        updatedAt: now,
        revision: (current?.revision ?? 0) + 1,
        synced: false,
      ),
    );
    _changes.add(null);
    return saved;
  }

  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    final observable = _store;
    if (observable is WatchableFeatureRecordStore) {
      yield* (observable as WatchableFeatureRecordStore)
          .watch(await _farmId, _kind)
          .map(
            (rows) => rows
                .map((r) => AnimalDto.fromJson(r.payload).toEntity())
                .where((a) => a.status.isInActiveHerd)
                .toList(growable: false),
          );
      return;
    }
    yield await getAll();
    await for (final _ in _changes.stream) yield await getAll();
  }

  @override
  Stream<void> watchChanges() async* {
    final observable = _store;
    if (observable is WatchableFeatureRecordStore) {
      yield* (observable as WatchableFeatureRecordStore)
          .watch(await _farmId, _kind)
          .map((_) {});
    } else {
      yield* _changes.stream;
    }
  }

  @override
  Future<bool> refreshFromRemote({bool force = false}) async => false;
  @override
  Future<List<AnimalEntity>> getAll() async => (await _read())
      .where((a) => a.status.isInActiveHerd)
      .toList(growable: false);
  @override
  Future<Set<Species>> getRegisteredSpecies() async =>
      (await _read()).map((animal) => animal.species).toSet();
  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async => _read();
  @override
  Future<List<AnimalEntity>> getPage({
    required int offset,
    required int limit,
  }) async => (await getAll()).skip(offset).take(limit).toList(growable: false);
  @override
  Future<AnimalEntity?> getByUuid(String uuid) => _readOne(uuid);
  @override
  Future<List<AnimalEntity>> getBySpecies(String speciesName) async =>
      (await getAll())
          .where((a) => a.species.name == speciesName)
          .toList(growable: false);
  @override
  Future<List<AnimalEntity>> getByPaddock(String paddockId) async =>
      (await getAll())
          .where((a) => a.currentLocationId == paddockId)
          .toList(growable: false);
  @override
  Future<List<AnimalEntity>> getByBatchUuid(String batchUuid) async =>
      (await getAll())
          .where((a) => a.batchUuid == batchUuid)
          .toList(growable: false);
  @override
  Future<List<AnimalEntity>> getByParentUuid(String parentUuid) async =>
      (await _read())
          .where((a) => a.sireUuid == parentUuid || a.damUuid == parentUuid)
          .toList(growable: false);
  @override
  Future<List<AnimalEntity>> getAnimalsRequiringAttention() async =>
      (await getAll())
          .where((a) => a.needsImmediateAttention)
          .toList(growable: false);
  @override
  Future<List<AnimalEntity>> getUnsynchronized() async =>
      (await getAll()).where((a) => !a.synced).toList(growable: false);
  @override
  Future<Map<LifeStage, int>> getActiveStageCounts() async {
    final counts = <LifeStage, int>{};
    for (final animal in await getAll())
      counts.update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
    return counts;
  }

  @override
  Future<Map<Species, Map<LifeStage, int>>> getActiveTaxonomyCounts() async {
    final counts = <Species, Map<LifeStage, int>>{};
    for (final animal in await getAll()) {
      counts
          .putIfAbsent(animal.species, () => <LifeStage, int>{})
          .update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  @override
  Future<AnimalEntity> updateDerivedLifecycle(AnimalEntity animal) =>
      _write(animal);
  @override
  Future<AnimalEntity> save(AnimalEntity animal) => _write(animal);
  @override
  Future<AnimalEntity> update(AnimalEntity animal) => _write(animal);
  @override
  Future<void> markAsSynced(String uuid, String remoteId) async {
    final animal = await _readOne(uuid);
    if (animal != null)
      await _write(
        animal.copyWith(
          synced: true,
          remoteId: remoteId,
          syncDate: DateTime.now().toUtc(),
        ),
        markUnsynced: false,
      );
  }

  @override
  Future<void> markAsUnsynchronized(String uuid) async {
    final animal = await _readOne(uuid);
    if (animal != null)
      await _write(animal.copyWith(synced: false, syncDate: null));
  }

  @override
  Future<void> delete(String uuid) async {
    final animal = await _readOne(uuid);
    if (animal != null)
      await _write(animal.copyWith(status: AnimalStatus.archived));
  }

  @override
  Future<void> purge(String uuid) async {
    await _store.softDelete(farmId: await _farmId, uuid: uuid, kind: _kind);
    _changes.add(null);
  }

  @override
  Future<void> clearAll() async {
    for (final animal in await _read()) await purge(animal.uuid);
    _changes.add(null);
  }

  @override
  Future<int> count() async => (await getAll()).length;
  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final animals = await getAll();
    return {
      'total': animals.length,
      'unsynced': animals.where((a) => !a.synced).length,
      'attention': animals.where((a) => a.needsImmediateAttention).length,
    };
  }
}

class WebCultivationRepository implements CultivationRepository {
  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) =>
      Stream.value(const <CultivationEntity>[]);
  @override
  Stream<List<CultivationEntity>> watchByLocation(
    String locationUuid, {
    bool includeArchived = false,
  }) => Stream.value(const <CultivationEntity>[]);
  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => const [];
  @override
  Future<CultivationEntity?> getByUuid(String uuid) async => null;
  @override
  Future<void> upsert(CultivationEntity cultivation) async {}
  @override
  Future<void> archive(String uuid) async {}
  @override
  Future<void> purge(String uuid) async {}
  @override
  Future<void> addHarvest(String uuid, HarvestRecord record) async {}
  @override
  Future<void> addWatering(String uuid, CropWateringRecord record) async {}
  @override
  Future<void> addHealth(String uuid, CropHealthRecord record) async {}
  @override
  Future<void> addTask(String uuid, CropTask task) async {}
  @override
  Future<void> completeTask(String uuid, String taskUuid) async {}
}

class WebAgendaRegistrationRepository implements AgendaRegistrationRepository {
  @override
  Future<List<AgendaRegistration>> fetchAll() async => const [];
  @override
  Future<List<AgendaRegistration>> fetchForEntries(
    Set<String> entryIds,
  ) async => const [];
  @override
  Future<AgendaRegistration?> getById(String id) async => null;
  @override
  Future<AgendaRegistration?> getForRow(
    String entryId,
    String? animalId,
  ) async => null;
  @override
  Future<void> save(AgendaRegistration registration) async {}
  @override
  Future<void> deleteForEntry(String entryId) async {}
  @override
  Future<void> clearAll() async {}
}

class WebWorkforceRepository implements WorkforceRepository {
  @override
  Future<List<WorkerProfile>> fetchWorkers({
    bool includeInactive = false,
  }) async => const [];
  @override
  Future<List<WorkTeam>> fetchTeams({bool includeInactive = false}) async =>
      const [];
  @override
  Future<void> saveWorker(WorkerProfile worker) async {}
  @override
  Future<void> saveTeam(WorkTeam team) async {}
  @override
  Future<void> archiveWorker(String id) async {}
  @override
  Future<void> archiveTeam(String id) async {}
  @override
  Future<void> replaceAll({
    required List<WorkerProfile> workers,
    required List<WorkTeam> teams,
  }) async {}
}

class WebProductionRecordRepository implements ProductionRecordRepository {
  @override
  Future<List<ProductionRecord>> getProductionRecords(
    String animalUuid,
  ) async => const [];
  @override
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  ) async => record;
  @override
  Future<void> deleteProductionRecord(String recordId) async {}
}

class WebReproductionRecordRepository implements ReproductionRecordRepository {
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async => const [];
  @override
  Future<List<ReproductionRecord>> getRecordsBySire(String sireUuid) async =>
      const [];
  @override
  Future<Map<String, List<ReproductionRecord>>>
  getReproductionRecordsForAnimals(Set<String> animalUuids) async => const {};
  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async => record;
  @override
  Future<void> deleteReproductionRecord(String recordId) async {}
  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
  getUpcomingCalvings(DateTime from, DateTime to) async => const [];
}

class WebCommercialRecordRepository implements CommercialRecordRepository {
  @override
  Future<List<CommercialRecord>> getCommercialRecords(
    String animalUuid,
  ) async => const [];
  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) async => record;
  @override
  Future<void> deleteCommercialRecord(String recordId) async {}
}

class WebCostRecordRepository implements CostRecordRepository {
  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) async => const [];
  @override
  Future<CostRecord> addCostRecord(
    String animalUuid,
    CostRecord record,
  ) async => record;
  @override
  Future<void> deleteCostRecord(String recordId) async {}
}

class WebCareRepository implements CareRepository {
  @override
  Future<List<CareRule>> getRules() async => const [];
  @override
  Future<Set<String>> getAllRuleIds() async => const {};
  @override
  Future<void> saveRule(CareRule rule) async {}
  @override
  Future<void> retireRule(String ruleId) async {}
  @override
  Future<List<CareRecord>> getRecordsForAnimal(String animalUuid) async =>
      const [];
  @override
  Future<Map<String, CareRecord>> getLatestRecordsByRule(
    String animalUuid,
  ) async => const {};
  @override
  Future<void> saveRecord(CareRecord record) async {}
  @override
  Future<void> deleteRecord(String recordId) async {}
  @override
  Future<List<ScheduledCare>> getPending({DateTime? until}) async => const [];
  @override
  Future<List<ScheduledCare>> getPendingForAnimal(String animalUuid) async =>
      const [];
  @override
  Future<void> saveSchedules(List<ScheduledCare> schedules) async {}
  @override
  Future<void> markDone(String scheduleId) async {}
  @override
  Future<void> clearGeneratedFor(String animalUuid) async {}
  @override
  Future<void> deleteAllForAnimal(String animalUuid) async {}
}

class WebMilkingRepository implements MilkingRepository {
  @override
  Future<MilkingSession?> getOpenDraft() async => null;
  @override
  Future<MilkingSession?> getSession(String uuid) async => null;
  @override
  Future<List<MilkingSession>> getAllSessions() async => const [];
  @override
  Future<List<MilkingEntry>> getAllEntries() async => const [];
  @override
  Future<List<MilkingEntry>> getEntries(String sessionUuid) async => const [];
  @override
  Future<List<MilkingRecord>> getRecordsByAnimal(String animalUuid) async =>
      const [];
  @override
  Future<Map<String, List<MilkingRecord>>> getRecordsForAnimals(
    Set<String> animalUuids, {
    DateTime? since,
  }) async => const {};
  @override
  Future<void> upsertSession(MilkingSession session) async {}
  @override
  Future<MilkingEntry> upsertEntry(MilkingEntry entry) async => entry;
  @override
  Future<void> deleteEntry(String uuid) async {}
  @override
  Future<void> finalizeSession(String sessionUuid) async {}
  @override
  Future<void> replaceAll({
    required List<MilkingSession> sessions,
    required List<MilkingEntry> entries,
  }) async {}
}

class WebFinanzasRepository implements FinanzasRepository {
  @override
  Future<IncomeRecord> updateIncome(IncomeRecord record) async =>
      throw UnsupportedError('Edición no disponible en este adaptador.');
  @override
  Future<GeneralExpenseRecord> updateExpense(
    GeneralExpenseRecord record,
  ) async => throw UnsupportedError('Edición no disponible en este adaptador.');
  @override
  Future<List<IncomeRecord>> getIncomes(DateRange range) async => const [];
  @override
  Future<List<IncomeRecord>> getAllIncomes() async => const [];
  @override
  Future<IncomeRecord> addIncome(IncomeRecord record) async => record;
  @override
  Future<void> deleteIncome(String id) async {}
  @override
  Future<List<GeneralExpenseRecord>> getExpenses(DateRange range) async =>
      const [];
  @override
  Future<List<GeneralExpenseRecord>> getAllExpenses() async => const [];
  @override
  Future<GeneralExpenseRecord> addExpense(GeneralExpenseRecord record) async =>
      record;
  @override
  Future<void> deleteExpense(String id) async {}
}

class WebRfidRepository implements RfidRepository {
  @override
  Future<List<RfidBindingRecord>> listBindings({String? animalUuid}) async =>
      const [];
  @override
  Future<RfidBindingRecord?> activeBindingForTag(String tagEpc) async => null;
  @override
  Future<RfidBindingRecord> assignTag({
    required String tagEpc,
    String? tagTid,
    required String animalUuid,
    RfidBindingSource? source,
  }) => throw UnsupportedError(
    'RFID web requiere un adaptador de hardware configurado.',
  );
  @override
  Future<void> retireBinding(String bindingUuid) async {}
  @override
  Future<void> saveScanSession(RfidScanSession session) async {}
  @override
  Future<List<RfidScanSession>> listScanSessions() async => const [];
}
