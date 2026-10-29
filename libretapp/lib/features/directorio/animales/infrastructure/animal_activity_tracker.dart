/// Shared persistence helpers for the directory's activity timestamp.
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_agenda_registration.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_care.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_entry.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_session.dart';

/// Keeps [IsarAnimal.lastUpdateDate] aligned with the activity that the
/// directory is meant to show. The helper deliberately knows about every
/// animal-linked collection so a delete can recompute the remaining maximum
/// instead of stamping the parent with the delete time.
class AnimalActivityTracker {
  const AnimalActivityTracker._();

  static Future<void> touch(
    Isar isar,
    String animalUuid,
    DateTime activityAt,
  ) async {
    final animal = await _findAnimal(isar, animalUuid);
    if (animal == null) return;
    animal
      ..lastUpdateDate = activityAt
      ..synced = false;
    await isar.isarAnimals.put(animal);
  }

  /// Recalculates the latest remaining record date for [animalUuid].
  ///
  /// [preserveSync] is used by the one-time historical reconstruction: it is
  /// a derived migration and must not create new synchronization work.
  static Future<void> recalculate(
    Isar isar,
    String animalUuid, {
    bool preserveSync = false,
  }) async {
    final animal = await _findAnimal(isar, animalUuid);
    if (animal == null) return;

    DateTime? latest;
    void add(DateTime? value) {
      if (value != null && (latest == null || value.isAfter(latest!))) {
        latest = value;
      }
    }

    for (final record
        in await isar.isarHealthRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.updatedAt ?? record.date);
    }
    for (final record
        in await isar.isarWeightRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.updatedAt ?? record.date);
    }
    for (final record
        in await isar.isarReproductionRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.updatedAt ?? record.actualCalvingDate ?? record.serviceDate!);
    }
    for (final record
        in await isar.isarMovementRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.updatedAt ?? record.date);
    }
    for (final record
        in await isar.isarProductionRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.date);
    }
    for (final record
        in await isar.isarCommercialRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.date);
    }
    for (final record
        in await isar.isarCostRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.date);
    }
    for (final record
        in await isar.isarCareRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .findAll()) {
      add(record.performedAt);
    }
    for (final record
        in await isar.isarAgendaRegistrations
            .where()
            .animalIdEqualTo(animalUuid)
            .findAll()) {
      add(record.updatedAt);
    }

    final entries = await isar.isarMilkingEntrys
        .where()
        .animalUuidEqualTo(animalUuid)
        .findAll();
    final sessionUuids = entries.map((entry) => entry.sessionUuid).toSet();
    for (final sessionUuid in sessionUuids) {
      final session = await isar.isarMilkingSessions
          .where()
          .uuidEqualTo(sessionUuid)
          .findFirst();
      if (session?.status != MilkingStatus.completed.name) continue;
      add(session!.updatedAt);
      for (final entry in entries.where(
        (entry) => entry.sessionUuid == sessionUuid,
      )) {
        add(entry.updatedAt);
      }
    }

    final next = latest == null || animal.creationDate.isAfter(latest!)
        ? animal.creationDate
        : latest!;
    animal.lastUpdateDate = next;
    if (!preserveSync) animal.synced = false;
    await isar.isarAnimals.put(animal);
  }

  static Future<IsarAnimal?> _findAnimal(Isar isar, String uuid) {
    return isar.isarAnimals.where().uuidEqualTo(uuid).findFirst();
  }
}
