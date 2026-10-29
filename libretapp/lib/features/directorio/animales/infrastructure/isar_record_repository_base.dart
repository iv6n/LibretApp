/// features > directorio > animales > infrastructure > isar_record_repository_base
library;
import 'package:libretapp/core/database/isar_write_transaction.dart';

import 'package:libretapp/core/utils/numeric_validation.dart';

import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_activity_tracker.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/animal_record_bulk_reader.dart';
import 'package:uuid/uuid.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';

/// Shared CRUD skeleton for the animal "child record" repositories (health,
/// movement, weight, cost, commercial, production, reproduction), which all
/// follow the same get-by-animal / add / delete-by-id shape against Isar.
///
/// Subclasses supply the collection accessor, the animal-scoped query
/// (sort field differs per record type), the entity<->model mapping, and an
/// optional [onSaved] hook for the repos that also need to update the
/// parent `IsarAnimal` (health/movement/weight).
abstract class IsarRecordRepositoryBase<
  TEntity,
  TIsarModel extends StableAnimalRecordModel
>
    implements AnimalRecordBulkReader<TEntity> {
  IsarRecordRepositoryBase(this._database);

  final IsarDatabase _database;

  /// Tag used for [LoggerService] entries.
  String get logTag;

  Future<Isar> get isar async => _database.initialize();

  IsarCollection<TIsarModel> collection(Isar isar);

  Future<List<TIsarModel>> queryByAnimal(
    IsarCollection<TIsarModel> collection,
    String animalUuid,
  );

  TEntity toEntity(TIsarModel model);

  TIsarModel toIsarModel(TEntity record, String animalUuid);

  void assignId(TIsarModel model, int id);

  String describeSaved(String animalUuid, TEntity saved);

  Future<List<TEntity>> getRecordsFor(String animalUuid) async {
    final db = await isar;
    final models = await queryByAnimal(collection(db), animalUuid);
    return models.map(toEntity).toList(growable: false);
  }

  @override
  Future<List<AnimalRecordExportItem<TEntity>>> getAllAnimalRecords() async {
    final db = await isar;
    final models = await collection(db).where().findAll();
    return models
        .map(
          (model) => AnimalRecordExportItem<TEntity>(
            animalUuid: model.animalUuid,
            recordUuid: model.recordUuid,
            record: toEntity(model),
          ),
        )
        .toList(growable: false);
  }

  Future<TEntity> addRecordFor(
    String animalUuid,
    TEntity record, {
    Future<void> Function(Isar isar, TIsarModel savedModel)? onSaved,
    Future<void> Function(Isar isar)? beforeWrite,
  }) async {
    final db = await isar;
    requireFiniteNumbers(record);
    final model = toIsarModel(record, animalUuid);
    final activityAt = DateTime.now();
    await withIsarWriteTransaction(db, () async {
      await beforeWrite?.call(db);
      if (model.recordUuid.isEmpty) {
        final existing = model.id == Isar.autoIncrement
            ? null
            : await collection(db).get(model.id);
        model.recordUuid = existing?.recordUuid.isNotEmpty == true
            ? existing!.recordUuid
            : const Uuid().v4();
      }
      final id = await collection(db).put(model);
      assignId(model, id);
      // Projection hooks already load and persist the parent animal (and set
      // its activity timestamp). Avoid writing the same parent twice for
      // those repositories; records without a projection still get the
      // lightweight activity touch.
      if (onSaved == null) {
        await AnimalActivityTracker.touch(db, animalUuid, activityAt);
      } else {
        await onSaved(db, model);
      }
    });
    final saved = toEntity(model);
    LoggerService.i(describeSaved(animalUuid, saved), tag: logTag);
    return saved;
  }

  /// Replaces the record [record] identifies, keeping its Isar id and its
  /// stable `recordUuid`.
  ///
  /// The write itself is the same `put` an add does — the unique+replace index
  /// on `recordUuid` means a put over an existing row updates it in place. What
  /// this adds over [addRecordFor] is the guard: an update with no id, or one
  /// whose row is gone, is a mistake, and inserting instead would leave the
  /// breeder with two rows where they were fixing one.
  Future<TEntity> updateRecordFor(
    String animalUuid,
    TEntity record, {
    Future<void> Function(Isar isar, TIsarModel savedModel)? onSaved,
    Future<void> Function(Isar isar)? beforeWrite,
  }) async {
    final db = await isar;
    requireFiniteNumbers(record);
    final model = toIsarModel(record, animalUuid);

    if (model.id == Isar.autoIncrement) {
      throw ArgumentError.value(
        record,
        'record',
        'updateRecordFor needs a record that is already stored; use '
            'addRecordFor for a new one.',
      );
    }

    final editedAt = DateTime.now();
    await withIsarWriteTransaction(db, () async {
      final stored = await collection(db).get(model.id);
      if (stored == null) {
        throw StateError(
          'No existe un registro con id ${model.id} para actualizar.',
        );
      }
      if (stored.animalUuid != animalUuid)
        throw ArgumentError('El registro pertenece a otro animal.');
      // Keep the identity the rest of the app refers to, whatever the caller
      // passed: agenda registrations and care cycles resolve records by uuid.
      model.recordUuid = stored.recordUuid;

      await beforeWrite?.call(db);
      final id = await collection(db).put(model);
      assignId(model, id);
      if (onSaved == null) {
        await AnimalActivityTracker.touch(db, animalUuid, editedAt);
      } else {
        await onSaved(db, model);
      }
    });

    final saved = toEntity(model);
    LoggerService.i('Registro corregido para $animalUuid', tag: logTag);
    return saved;
  }

  Future<void> deleteRecordById(String recordId) async {
    final db = await isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await withIsarWriteTransaction(db, () async {
      final stored = await collection(db).get(id);
      final animalUuid = stored?.animalUuid;
      if (animalUuid != null)
        await AnimalProjectionRecalculator.recalculate(
          db,
          animalUuid,
          updateActivityTimestamp: false,
        );
      await collection(db).delete(id);
      if (animalUuid != null && animalUuid.isNotEmpty) {
        await AnimalActivityTracker.recalculate(db, animalUuid);
        // The animal's denormalized fields were derived from this record too;
        // without this a deleted weighing left its value on the animal and a
        // deleted death record left the animal dead.
        await AnimalProjectionRecalculator.recalculate(
          db,
          animalUuid,
          updateActivityTimestamp: false,
        );
      }
    });
  }
}
