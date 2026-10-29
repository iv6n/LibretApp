/// features › directorio › animales › infrastructure › movement_record_repository_isar
library;
import 'package:libretapp/core/database/isar_write_transaction.dart';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import 'isar/isar_animal.dart';
import '../domain/services/animal_record_validation.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/isar/isar_lote.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class MovementRecordRepositoryIsar
    extends IsarRecordRepositoryBase<MovementRecord, IsarMovementRecord>
    implements
        MovementRecordRepository,
        AtomicMovementRepository,
        MovementRecordUuidLookup,
        MovementRecordRecentLookup,
        EditableRecordRepository<MovementRecord> {
  MovementRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'MovementRecordRepositoryIsar';

  @override
  IsarCollection<IsarMovementRecord> collection(Isar isar) =>
      isar.isarMovementRecords;

  @override
  Future<List<IsarMovementRecord>> queryByAnimal(
    IsarCollection<IsarMovementRecord> collection,
    String animalUuid,
  ) => collection
      .where()
      .animalUuidEqualTo(animalUuid)
      .sortByDateDesc()
      .findAll();

  @override
  IsarMovementRecord toIsarModel(MovementRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  MovementRecord toEntity(IsarMovementRecord model) => model.toEntity();

  @override
  void assignId(IsarMovementRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, MovementRecord saved) =>
      'Movimiento guardado para $animalUuid (${saved.id})';

  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

  @override
  Future<List<({String animalUuid, MovementRecord record})>>
  getRecentMovementRecords({int limit = 5}) async {
    final db = await isar;
    final models = await db.isarMovementRecords
        .where()
        .sortByDateDesc()
        .limit(limit)
        .findAll();
    return models
        .map((m) => (animalUuid: m.animalUuid, record: m.toEntity()))
        .toList(growable: false);
  }

  @override
  Future<Map<String, MovementRecord>> getMovementRecordsByRecordUuids(
    Set<String> recordUuids,
  ) async {
    if (recordUuids.isEmpty) return const {};
    final db = await isar;
    final records = await db.isarMovementRecords
        .filter()
        .anyOf(recordUuids, (q, uuid) => q.recordUuidEqualTo(uuid))
        .findAll();
    return {for (final record in records) record.recordUuid: record.toEntity()};
  }

  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) async => (await addMovementRecordsAtomically([
    MovementBatchEntry(animalUuid, record.copyWith(recordUuid: record.recordUuid ?? const Uuid().v4())),
  ])).single;

  Future<MovementRecord> _writeMovement(Isar db, MovementBatchEntry entry) async {
    final record = entry.record;
    final uuid = record.recordUuid;
    if (uuid == null || uuid.isEmpty) throw ArgumentError('Falta la identidad del movimiento.');
    final previous = await db.isarMovementRecords.where().recordUuidEqualTo(uuid).findFirst();
    if (previous != null) {
      if (previous.animalUuid != entry.animalUuid || previous.toLocation != record.toLocation ||
          previous.fromLocation != record.fromLocation || previous.clearsLocation != record.clearsLocation ||
          previous.date != record.date || previous.reason != record.reason.name ||
          previous.notes != record.notes || previous.movedBy != record.movedBy ||
          previous.latitude != record.latitude || previous.longitude != record.longitude ||
          previous.accuracyMeters != record.accuracyMeters) {
        throw ArgumentError('El movimiento ya existe con otra captura.');
      }
      return previous.toEntity();
    }
    final animal = await db.isarAnimals.where().uuidEqualTo(entry.animalUuid).findFirst();
    if (animal == null) throw StateError('Animal no encontrado.');
    AnimalRecordValidation.operation(animal.toEntity(), record.date);
    if (!record.clearsLocation && record.toLocation.trim().isEmpty) {
      throw ArgumentError('Indica el destino o selecciona sin ubicación.');
    }
    await AnimalProjectionRecalculator.prepareLocationProjection(db, entry.animalUuid);
    final model = record.toIsar(entry.animalUuid)..id = Isar.autoIncrement;
    await db.isarMovementRecords.put(model);
    await AnimalProjectionRecalculator.recalculate(db, entry.animalUuid);
    return model.toEntity();
  }

  @override
  Future<List<MovementRecord>> addMovementRecordsAtomically(List<MovementBatchEntry> entries) async {
    final db = await isar;
    final saved = <MovementRecord>[];
    await withIsarWriteTransaction(db, () async {
      for (final entry in entries) { saved.add(await _writeMovement(db, entry)); }
    });
    return saved;
  }

  @override
  Future<void> moveLotAtomically(String lotUuid, String? destinationId) async {
    final db = await isar;
    await withIsarWriteTransaction(db, () async {
      final lot = await db.isarLotes.where().uuidEqualTo(lotUuid).findFirst();
      if (lot == null) throw StateError('Lote no encontrado.');
      final animals = await db.isarAnimals.filter().batchUuidEqualTo(lotUuid).findAll();
      final now = DateTime.now();
      for (final animal in animals.where((a) => a.toEntity().status.isInActiveHerd)) {
        if (animal.currentLocationId == destinationId) continue;
        await _writeMovement(db, MovementBatchEntry(animal.uuid, MovementRecord(
          fromLocation: animal.currentLocationId, toLocation: destinationId ?? '',
          clearsLocation: destinationId == null, date: now,
          recordUuid: const Uuid().v4(), reason: MovementReason.paddockRotation)));
      }
      lot.currentLocationId = destinationId;
      lot.lastUpdateDate = now;
      await db.isarLotes.put(lot);
    });
  }

  @override
  Future<void> deleteMovementRecord(String recordId) =>
      deleteRecordById(recordId);

  @override
  Future<MovementRecord> updateRecord(
    String animalUuid,
    MovementRecord record,
  ) => updateRecordFor(
    animalUuid,
    record,
    beforeWrite: (isar) => AnimalProjectionRecalculator.prepareLocationProjection(isar, animalUuid),
    onSaved: (isar, _) =>
        AnimalProjectionRecalculator.recalculate(isar, animalUuid),
  );
}
