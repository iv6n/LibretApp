/// features › directorio › animales › infrastructure › commercial_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';

class CommercialRecordRepositoryIsar
    extends IsarRecordRepositoryBase<CommercialRecord, IsarCommercialRecord>
    implements CommercialRecordRepository {
  CommercialRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'CommercialRecordRepositoryIsar';

  @override
  IsarCollection<IsarCommercialRecord> collection(Isar isar) => isar.isarCommercialRecords;

  @override
  Future<List<IsarCommercialRecord>> queryByAnimal(
    IsarCollection<IsarCommercialRecord> collection,
    String animalUuid,
  ) => collection.filter().animalUuidEqualTo(animalUuid).sortByDateDesc().findAll();

  @override
  IsarCommercialRecord toIsarModel(CommercialRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

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
    onSaved: (isar, _) => _applyCommercialEffects(isar, animalUuid, record),
  );

  /// Takes the animal out of the herd when it leaves it.
  ///
  /// Until this existed, [AnimalStatus.sold] and [AnimalStatus.dead] were
  /// never written by any code path: you could sell an animal and it kept
  /// counting in the inventory, the totals and the dashboard.
  Future<void> _applyCommercialEffects(
    Isar isar,
    String animalUuid,
    CommercialRecord record,
  ) async {
    final status = _statusFor(record.type);
    if (status == null) return;

    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(animalUuid)
        .findFirst();
    if (animal == null) return;

    animal
      ..status = status.name
      ..lastUpdateDate = DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(animal);
  }

  AnimalStatus? _statusFor(CommercialRecordType type) {
    switch (type) {
      case CommercialRecordType.sale:
      case CommercialRecordType.writeOffSale:
        return AnimalStatus.sold;
      case CommercialRecordType.writeOffDeath:
        return AnimalStatus.dead;
      case CommercialRecordType.purchase:
      case CommercialRecordType.ownershipChange:
      case CommercialRecordType.priceUpdate:
        // A purchase brings it in and a change of owner leaves it grazing
        // right where it was: neither takes the animal out of the herd.
        return null;
    }
  }

  @override
  Future<void> deleteCommercialRecord(String recordId) => deleteRecordById(recordId);
}
