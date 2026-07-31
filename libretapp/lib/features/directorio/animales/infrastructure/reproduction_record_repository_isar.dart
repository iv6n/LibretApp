/// features › directorio › animales › infrastructure › reproduction_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
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
  ) => addRecordFor(animalUuid, record);

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
