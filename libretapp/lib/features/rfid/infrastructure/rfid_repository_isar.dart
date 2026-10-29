/// Isar-backed RFID association repository.
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/utils/numeric_validation.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/rfid/domain/rfid_models.dart';
import 'package:libretapp/features/rfid/infrastructure/isar_rfid.dart';
import 'package:uuid/uuid.dart';

class RfidRepositoryIsar implements RfidRepository {
  RfidRepositoryIsar(this._database);

  final IsarDatabase _database;
  static const _logTag = 'RfidRepositoryIsar';

  Future<Isar> get _isar => _database.initialize();

  @override
  Future<List<RfidBindingRecord>> listBindings({String? animalUuid}) async {
    final isar = await _isar;
    final models = await isar.isarRfidBindings.where().findAll();
    return models
        .where((model) => animalUuid == null || model.animalUuid == animalUuid)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  @override
  Future<RfidBindingRecord?> activeBindingForTag(String tagEpc) async {
    final normalized = RfidTagNormalizer.normalize(tagEpc);
    final isar = await _isar;
    final models = await isar.isarRfidBindings
        .filter()
        .tagEpcEqualTo(normalized)
        .findAll();
    for (final model in models) {
      if (model.status == RfidBindingStatus.active.name) {
        return model.toEntity();
      }
    }
    return null;
  }

  @override
  Future<RfidBindingRecord> assignTag({
    required String tagEpc,
    String? tagTid,
    required String animalUuid,
    RfidBindingSource source = RfidBindingSource.reader,
  }) async {
    final normalized = RfidTagNormalizer.normalize(tagEpc);
    if (normalized.isEmpty) {
      throw const RfidBindingConflict('La etiqueta RFID está vacía.');
    }

    final isar = await _isar;
    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(animalUuid)
        .findFirst();
    if (animal == null) {
      throw const RfidBindingConflict('No se encontró el animal seleccionado.');
    }
    final activeForTag = await isar.isarRfidBindings
        .filter()
        .tagEpcEqualTo(normalized)
        .findAll();
    final otherOwner = activeForTag.where(
      (binding) =>
          binding.status == RfidBindingStatus.active.name &&
          binding.animalUuid != animalUuid,
    );
    if (otherOwner.isNotEmpty) {
      throw const RfidBindingConflict(
        'Esta etiqueta ya está asignada a otro animal.',
      );
    }

    final now = DateTime.now();
    final currentForAnimal = await isar.isarRfidBindings
        .filter()
        .animalUuidEqualTo(animalUuid)
        .findAll();
    final binding = RfidBindingRecord(
      uuid: const Uuid().v4(),
      tagEpc: normalized,
      tagTid: tagTid?.trim().isEmpty == true ? null : tagTid?.trim(),
      animalUuid: animalUuid,
      status: RfidBindingStatus.active,
      source: source,
      assignedAt: now,
      updatedAt: now,
    );

    await isar.writeTxn(() async {
      for (final previous in currentForAnimal.where(
        (item) => item.status == RfidBindingStatus.active.name,
      )) {
        previous
          ..status = RfidBindingStatus.retired.name
          ..retiredAt = now
          ..updatedAt = now;
        await isar.isarRfidBindings.put(previous);
      }
      await isar.isarRfidBindings.put(binding.toIsar());
      animal
        ..rfidTag = normalized
        ..lastUpdateDate = now
        ..synced = false;
      await isar.isarAnimals.put(animal);
    });
    LoggerService.i('RFID $normalized asignado a $animalUuid', tag: _logTag);
    return binding;
  }

  @override
  Future<void> retireBinding(String bindingUuid) async {
    final isar = await _isar;
    final binding = await isar.isarRfidBindings
        .where()
        .uuidEqualTo(bindingUuid)
        .findFirst();
    if (binding == null) return;
    final now = DateTime.now();
    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(binding.animalUuid)
        .findFirst();
    await isar.writeTxn(() async {
      binding
        ..status = RfidBindingStatus.retired.name
        ..retiredAt = now
        ..updatedAt = now;
      await isar.isarRfidBindings.put(binding);
      if (animal != null && animal.rfidTag == binding.tagEpc) {
        animal
          ..rfidTag = null
          ..lastUpdateDate = now
          ..synced = false;
        await isar.isarAnimals.put(animal);
      }
    });
  }

  @override
  Future<void> saveScanSession(RfidScanSession session) async {
    requireFiniteNumbers(session);
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarRfidScanSessions.put(session.toIsar());
    });
  }

  @override
  Future<List<RfidScanSession>> listScanSessions() async {
    final isar = await _isar;
    final sessions = await isar.isarRfidScanSessions.where().findAll();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions
        .map((session) => session.toEntity())
        .toList(growable: false);
  }
}
