/// features › directorio › animales › infrastructure › production_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';

class ProductionRecordRepositoryIsar
    extends IsarRecordRepositoryBase<ProductionRecord, IsarProductionRecord>
    implements ProductionRecordRepository {
  ProductionRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'ProductionRecordRepositoryIsar';

  @override
  IsarCollection<IsarProductionRecord> collection(Isar isar) => isar.isarProductionRecords;

  @override
  Future<List<IsarProductionRecord>> queryByAnimal(
    IsarCollection<IsarProductionRecord> collection,
    String animalUuid,
  ) => collection.filter().animalUuidEqualTo(animalUuid).sortByDateDesc().findAll();

  @override
  IsarProductionRecord toIsarModel(ProductionRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  ProductionRecord toEntity(IsarProductionRecord model) => model.toEntity();

  @override
  void assignId(IsarProductionRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, ProductionRecord saved) =>
      'Registro productivo guardado para $animalUuid (${saved.id})';

  @override
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

  @override
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) => _applyProductionEffects(isar, animalUuid, record),
  );

  /// Copies a body-condition score onto the animal so the card and the
  /// nutrition rules read the latest one instead of the value typed at
  /// registration.
  Future<void> _applyProductionEffects(
    Isar isar,
    String animalUuid,
    ProductionRecord record,
  ) async {
    if (record.type != ProductionRecordType.bodyConditionScore) return;
    final score = record.score;
    if (score == null) return;

    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(animalUuid)
        .findFirst();
    if (animal == null) return;

    animal
      ..bodyConditionScore = score
      ..lastUpdateDate = DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(animal);
  }

  @override
  Future<void> deleteProductionRecord(String recordId) => deleteRecordById(recordId);
}
