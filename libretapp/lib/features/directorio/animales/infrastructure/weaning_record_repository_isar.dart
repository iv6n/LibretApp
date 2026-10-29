library;

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:libretapp/core/database/isar_database.dart';
import '../domain/animal_domain.dart';
import '../domain/repositories/weaning_record_repository.dart';
import '../domain/repositories/animal_record_bulk_reader.dart';
import '../domain/services/animal_record_validation.dart';
import 'animal_projection_recalculator.dart';
import 'isar/isar_animal.dart';
import 'isar/isar_weight_record.dart';
import 'isar/isar_weaning_record.dart';

/// A weaning and its optional weighing are one atomic operation.
class WeaningRecordRepositoryIsar implements WeaningRecordRepository {
  WeaningRecordRepositoryIsar(this.database);
  final IsarDatabase database;

  @override
  Future<List<WeaningRecord>> getWeaningRecords(String animalUuid) async {
    final db = await database.initialize();
    return (await db.isarWeaningRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .sortByDateDesc()
            .findAll())
        .map((r) => r.entity)
        .toList();
  }

  @override
  Future<Map<String, List<WeaningRecord>>> getWeaningRecordsForAnimals(
    Set<String> animalUuids,
  ) async {
    if (animalUuids.isEmpty) return {};
    final db = await database.initialize();
    final records = await db.isarWeaningRecords
        .filter()
        .anyOf(animalUuids, (q, uuid) => q.animalUuidEqualTo(uuid))
        .findAll();
    final result = <String, List<WeaningRecord>>{};
    for (final record in records) {
      (result[record.animalUuid] ??= []).add(record.entity);
    }
    return result;
  }

  @override
  Future<List<AnimalRecordExportItem<WeaningRecord>>>
  getAllAnimalRecords() async {
    final db = await database.initialize();
    return (await db.isarWeaningRecords.where().findAll())
        .map(
          (r) => AnimalRecordExportItem(
            animalUuid: r.animalUuid,
            recordUuid: r.recordUuid,
            record: r.entity,
          ),
        )
        .toList();
  }

  @override
  Future<WeaningRecord> updateRecord(
    String animalUuid,
    WeaningRecord record,
  ) async {
    if (animalUuid != record.animalUuid || record.id == null)
      throw ArgumentError('Identidad de destete inválida.');
    final db = await database.initialize();
    final existing = await db.isarWeaningRecords.get(int.parse(record.id!));
    if (existing == null || existing.animalUuid != animalUuid)
      throw StateError('El destete ya no existe.');
    return save(record);
  }

  @override
  Future<WeaningRecord> save(WeaningRecord record) async {
    final db = await database.initialize();
    late IsarWeaningRecord saved;
    await db.writeTxn(() async {
      final animal = await db.isarAnimals
          .where()
          .uuidEqualTo(record.animalUuid)
          .findFirst();
      if (animal == null) throw StateError('Animal no encontrado.');
      if (animal.species != Species.cattle.name)
        throw ArgumentError(
          'El registro de destete está disponible para bovinos.',
        );
      final stored = record.id != null
          ? await db.isarWeaningRecords.get(int.parse(record.id!))
          : record.recordUuid == null
          ? null
          : await db.isarWeaningRecords
                .where()
                .recordUuidEqualTo(record.recordUuid!)
                .findFirst();
      if (stored != null && stored.animalUuid != record.animalUuid)
        throw ArgumentError('El destete pertenece a otro animal.');
      AnimalRecordValidation.operation(
        animal.toEntity(),
        record.date,
        editing: stored != null || record.id != null,
      );
      final others = await db.isarWeaningRecords
          .where()
          .animalUuidEqualTo(record.animalUuid)
          .findAll();
      if (others.any(
        (r) => r.id != stored?.id && r.recordUuid != record.recordUuid,
      )) {
        throw StateError(
          'Este bovino ya tiene un destete. Corrige el registro existente.',
        );
      }
      final weight = record.weightKg;
      if (weight != null && (!weight.isFinite || weight <= 0))
        throw ArgumentError('Ingresa un peso positivo en kg.');
      final model = IsarWeaningRecord()
        ..id =
            stored?.id ??
            (record.id == null ? Isar.autoIncrement : int.parse(record.id!))
        ..recordUuid =
            stored?.recordUuid ?? record.recordUuid ?? const Uuid().v4()
        ..animalUuid = record.animalUuid
        ..date = record.date
        ..weightKg = weight
        ..weightMethod = record.weightMethod.name
        ..performedBy = record.performedBy
        ..notes = record.notes
        ..updatedAt = DateTime.now()
        ..previousProductionStage =
            stored?.previousProductionStage ?? animal.productionStage
        ..previousCategory = stored?.previousCategory ?? animal.category;
      final weightUuid = stored?.weightRecordUuid ?? record.weightRecordUuid;
      if (weight != null) {
        await AnimalProjectionRecalculator.prepareWeightProjection(
          db,
          animal.uuid,
        );
        // Reload projection metadata before persisting the category.
        final baseline = await db.isarAnimals.get(animal.id);
        animal.registrationWeight = baseline?.registrationWeight;
        animal.weightProjectionInitialized =
            baseline?.weightProjectionInitialized;
        model.weightRecordUuid =
            weightUuid ?? 'weaning-weight:${model.recordUuid}';
        final existingWeight = await db.isarWeightRecords
            .where()
            .recordUuidEqualTo(model.weightRecordUuid!)
            .findFirst();
        if (existingWeight != null && existingWeight.animalUuid != animal.uuid) {
          throw ArgumentError('El pesaje asociado pertenece a otro animal.');
        }
        final weighing =
            WeightRecord(
                date: record.date,
                weight: weight,
                method: record.weightMethod,
                measuredBy: record.performedBy,
                recordUuid: model.weightRecordUuid,
                lotUuid: animal.batchUuid,
                notes: 'Peso al destete',
              ).toIsar(record.animalUuid)
              ..id = existingWeight?.id ?? Isar.autoIncrement
              ..createdAt = existingWeight?.createdAt ?? DateTime.now();
        await db.isarWeightRecords.put(weighing);
      } else if (weightUuid != null) {
        await db.isarWeightRecords
            .where()
            .recordUuidEqualTo(weightUuid)
            .deleteAll();
      }
      model.id = await db.isarWeaningRecords.put(model);
      animal.productionStage = 'postWeaning';
      if (animal.category == Category.calf.name)
        animal.category = Category.weaned.name;
      await db.isarAnimals.put(animal);
      await AnimalProjectionRecalculator.recalculate(db, animal.uuid);
      saved = model;
    });
    return saved.entity;
  }

  @override
  Future<void> deleteWeaningRecord(String recordId) async {
    final db = await database.initialize();
    await db.writeTxn(() async {
      final stored = await db.isarWeaningRecords.get(int.parse(recordId));
      if (stored == null) return;
      if (stored.weightRecordUuid != null) {
        await AnimalProjectionRecalculator.prepareWeightProjection(
          db,
          stored.animalUuid,
        );
        await db.isarWeightRecords
            .where()
            .recordUuidEqualTo(stored.weightRecordUuid!)
            .deleteAll();
      }
      await db.isarWeaningRecords.delete(stored.id);
      final animal = await db.isarAnimals
          .where()
          .uuidEqualTo(stored.animalUuid)
          .findFirst();
      if (animal != null) {
        if (animal.productionStage == 'postWeaning')
          animal.productionStage = stored.previousProductionStage ?? 'unknown';
        if (animal.category == Category.weaned.name)
          animal.category = stored.previousCategory ?? Category.calf.name;
        await db.isarAnimals.put(animal);
        await AnimalProjectionRecalculator.recalculate(db, animal.uuid);
      }
    });
  }
}
