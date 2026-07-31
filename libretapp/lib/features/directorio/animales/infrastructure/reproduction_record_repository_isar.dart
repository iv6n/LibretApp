/// features › directorio › animales › infrastructure › reproduction_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/reproduction_scheduler.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';

class ReproductionRecordRepositoryIsar
    extends IsarRecordRepositoryBase<ReproductionRecord, IsarReproductionRecord>
    implements ReproductionRecordRepository {
  ReproductionRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'ReproductionRecordRepositoryIsar';

  @override
  IsarCollection<IsarReproductionRecord> collection(Isar isar) => isar.isarReproductionRecords;

  @override
  Future<List<IsarReproductionRecord>> queryByAnimal(
    IsarCollection<IsarReproductionRecord> collection,
    String animalUuid,
  ) => collection.filter().animalUuidEqualTo(animalUuid).sortByServiceDateDesc().findAll();

  @override
  IsarReproductionRecord toIsarModel(ReproductionRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  ReproductionRecord toEntity(IsarReproductionRecord model) => model.toEntity();

  @override
  void assignId(IsarReproductionRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, ReproductionRecord saved) =>
      'Evento reproductivo guardado para $animalUuid (${saved.id})';

  @override
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

  @override
  Future<List<ReproductionRecord>> getRecordsBySire(String sireUuid) async {
    if (sireUuid.trim().isEmpty) return const [];

    final db = await isar;
    final records = await db.isarReproductionRecords
        .where()
        .maleSireUuidEqualTo(sireUuid)
        .findAll();

    final entities = records.map((record) => record.toEntity()).toList()
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    return List<ReproductionRecord>.unmodifiable(entities);
  }

  @override
  Future<Map<String, List<ReproductionRecord>>>
  getReproductionRecordsForAnimals(Set<String> animalUuids) async {
    if (animalUuids.isEmpty) return const {};

    final db = await isar;
    final records = await db.isarReproductionRecords
        .filter()
        .anyOf(animalUuids, (q, uuid) => q.animalUuidEqualTo(uuid))
        .sortByServiceDateDesc()
        .findAll();

    final grouped = <String, List<ReproductionRecord>>{};
    for (final record in records) {
      grouped
          .putIfAbsent(record.animalUuid, () => <ReproductionRecord>[])
          .add(record.toEntity());
    }
    return grouped;
  }

  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) => _applyReproductionEffects(isar, animalUuid, record),
  );

  /// Projects the reproduction record onto the animal row.
  ///
  /// Without this the record was stored but the cow never changed: her status,
  /// service dates and expected calving stayed as they were, which left the
  /// card, the dashboard and three advisor rules reading fields nobody wrote.
  ///
  /// The record wins over a manually set status, matching how a vaccination
  /// record already flips `vaccinated` without asking.
  Future<void> _applyReproductionEffects(
    Isar isar,
    String animalUuid,
    ReproductionRecord record, {
    DateTime? now,
  }) async {
    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(animalUuid)
        .findFirst();
    if (animal == null) return;

    // Never move the last service backwards: editing an old record must not
    // rewrite history with a stale date.
    final currentLast = animal.lastServiceDate;
    if (currentLast == null || record.serviceDate.isAfter(currentLast)) {
      animal.lastServiceDate = record.serviceDate;
    }
    animal.firstServiceDate ??= record.serviceDate;

    _applyStatusTransition(animal, record);

    animal
      ..lastUpdateDate = now ?? DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(animal);

    await _markSireServed(isar, record, now);
  }

  /// Stamps the service on the bull too, so his profile can answer "when did
  /// this sire last work". Only his dates move — the status transition above
  /// is guarded by sex and would be meaningless for him.
  Future<void> _markSireServed(
    Isar isar,
    ReproductionRecord record,
    DateTime? now,
  ) async {
    final sireUuid = record.maleSireUuid?.trim();
    if (sireUuid == null || sireUuid.isEmpty) return;

    final sire = await isar.isarAnimals
        .where()
        .uuidEqualTo(sireUuid)
        .findFirst();
    // A sire typed in as free text, or one that is not in the herd, simply has
    // nowhere to record this.
    if (sire == null) return;

    final currentLast = sire.lastServiceDate;
    if (currentLast == null || record.serviceDate.isAfter(currentLast)) {
      sire.lastServiceDate = record.serviceDate;
    }
    sire.firstServiceDate ??= record.serviceDate;

    sire
      ..lastUpdateDate = now ?? DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(sire);
  }

  void _applyStatusTransition(IsarAnimal animal, ReproductionRecord record) {
    // A male carries no reproductive state from a service record, and
    // neutered/retired are management decisions rather than evidence of an
    // event, so neither is overwritten.
    if (animal.sex != Sex.female.name) return;
    const untouchable = {'neutered', 'retired'};
    if (untouchable.contains(animal.reproductiveStatus)) return;

    if (record.actualCalvingDate != null) {
      animal
        ..reproductiveStatus = ReproductiveStatus.lactating.name
        ..expectedCalvingDate = null;
      return;
    }

    switch (record.pregnancyResult) {
      case PregnancyCheckResult.positive:
        animal
          ..reproductiveStatus = ReproductiveStatus.pregnant.name
          ..expectedCalvingDate = _resolveExpectedCalving(record);
      case PregnancyCheckResult.negative:
        animal
          ..reproductiveStatus = ReproductiveStatus.active.name
          ..expectedCalvingDate = null;
      case PregnancyCheckResult.uncertain:
      case PregnancyCheckResult.notChecked:
      case null:
        // Served but not yet diagnosed: she is in the breeding cycle, and the
        // projected date gives the dashboard something to count down to.
        animal
          ..reproductiveStatus = ReproductiveStatus.active.name
          ..expectedCalvingDate = _resolveExpectedCalving(record);
    }
  }

  /// The date the user typed, or the standard gestation projected from the
  /// service when they left it empty.
  DateTime _resolveExpectedCalving(ReproductionRecord record) {
    return record.expectedCalvingDate ??
        const ReproductionScheduler()
            .estimate(serviceDate: record.serviceDate)
            .dueDate;
  }

  @override
  Future<void> deleteReproductionRecord(String recordId) => deleteRecordById(recordId);

  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
      getUpcomingCalvings(DateTime from, DateTime to) async {
    final db = await isar;
    final records = await db.isarReproductionRecords
        .filter()
        .expectedCalvingDateBetween(from, to)
        .actualCalvingDateIsNull()
        .findAll();
    return records
        .map(
          (r) => (
            animalUuid: r.animalUuid,
            expectedCalvingDate: r.expectedCalvingDate!,
          ),
        )
        .toList(growable: false);
  }
}
