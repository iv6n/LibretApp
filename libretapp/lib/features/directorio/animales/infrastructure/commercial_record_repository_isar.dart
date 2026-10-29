/// features › directorio › animales › infrastructure › commercial_record_repository_isar
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class CommercialRecordRepositoryIsar
    extends IsarRecordRepositoryBase<CommercialRecord, IsarCommercialRecord>
    implements
        CommercialRecordRepository,
        EditableRecordRepository<CommercialRecord> {
  CommercialRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'CommercialRecordRepositoryIsar';

  @override
  IsarCollection<IsarCommercialRecord> collection(Isar isar) =>
      isar.isarCommercialRecords;

  @override
  Future<List<IsarCommercialRecord>> queryByAnimal(
    IsarCollection<IsarCommercialRecord> collection,
    String animalUuid,
  ) => collection
      .where()
      .animalUuidEqualTo(animalUuid)
      .sortByDateDesc()
      .findAll();

  @override
  IsarCommercialRecord toIsarModel(
    CommercialRecord record,
    String animalUuid,
  ) => record.toIsar(animalUuid);

  @override
  CommercialRecord toEntity(IsarCommercialRecord model) => model.toEntity();

  @override
  void assignId(IsarCommercialRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, CommercialRecord saved) =>
      'Registro comercial guardado para $animalUuid (${saved.id})';

  @override
  Future<List<CommercialRecord>> getCommercialRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) =>
        AnimalProjectionRecalculator.recalculate(isar, animalUuid),
  );

  @override
  Future<void> deleteCommercialRecord(String recordId) =>
      deleteRecordById(recordId);

  @override
  Future<CommercialRecord> updateRecord(
    String animalUuid,
    CommercialRecord record,
  ) => updateRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) =>
        AnimalProjectionRecalculator.recalculate(isar, animalUuid),
  );
}
