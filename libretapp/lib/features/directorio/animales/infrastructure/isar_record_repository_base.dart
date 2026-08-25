/// features > directorio > animales > infrastructure > isar_record_repository_base
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_activity_tracker.dart';
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
  TIsarModel extends StableRecordModel
> {
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

  Future<TEntity> addRecordFor(
    String animalUuid,
    TEntity record, {
    Future<void> Function(Isar isar, TIsarModel savedModel)? onSaved,
  }) async {
    final db = await isar;
    final model = toIsarModel(record, animalUuid);
    final activityAt = DateTime.now();
    await db.writeTxn(() async {
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
      await AnimalActivityTracker.touch(db, animalUuid, activityAt);
      if (onSaved != null) await onSaved(db, model);
    });
    final saved = toEntity(model);
    LoggerService.i(describeSaved(animalUuid, saved), tag: logTag);
    return saved;
  }

  Future<void> deleteRecordById(String recordId) async {
    final db = await isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await db.writeTxn(() async {
      final stored = await collection(db).get(id);
      final animalUuid = stored == null
          ? null
          : (stored as dynamic).animalUuid as String?;
      await collection(db).delete(id);
      if (animalUuid != null && animalUuid.isNotEmpty) {
        await AnimalActivityTracker.recalculate(db, animalUuid);
        // The animal's denormalized fields were derived from this record too;
        // without this a deleted weighing left its value on the animal and a
        // deleted death record left the animal dead.
        await AnimalProjectionRecalculator.recalculate(db, animalUuid);
      }
    });
  }
}
