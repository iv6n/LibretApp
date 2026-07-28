/// features › directorio › animales › infrastructure › cost_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';

class CostRecordRepositoryIsar
    extends IsarRecordRepositoryBase<CostRecord, IsarCostRecord>
    implements CostRecordRepository {
  CostRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'CostRecordRepositoryIsar';

  @override
  IsarCollection<IsarCostRecord> collection(Isar isar) => isar.isarCostRecords;

  @override
  Future<List<IsarCostRecord>> queryByAnimal(
    IsarCollection<IsarCostRecord> collection,
    String animalUuid,
  ) => collection.filter().animalUuidEqualTo(animalUuid).sortByDateDesc().findAll();

  @override
  IsarCostRecord toIsarModel(CostRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  CostRecord toEntity(IsarCostRecord model) => model.toEntity();

  @override
  void assignId(IsarCostRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, CostRecord saved) =>
      'Costo guardado para $animalUuid (${saved.id})';

  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) => getRecordsFor(animalUuid);

  @override
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record) =>
      addRecordFor(animalUuid, record);

  @override
  Future<void> deleteCostRecord(String recordId) => deleteRecordById(recordId);
}
