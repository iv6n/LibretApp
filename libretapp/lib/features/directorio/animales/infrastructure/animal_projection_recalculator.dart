/// Rebuilds the animal fields that are derived from its operational records.
///
/// `IsarAnimal` denormalizes a handful of values so the directory can render a
/// card without opening every child collection: current weight, body condition,
/// where the animal is standing, the health flags, and whether it is still in
/// the herd. Each record repository used to *project* onto those fields on save
/// — last write wins, with no counterpart for any other edit.
///
/// That was fine while records could only be appended. It stops being fine the
/// moment a record can be corrected or removed: editing a two-year-old weighing
/// would overwrite the animal's current weight with that old value, and
/// deleting the record that made an animal `dead` would leave it dead forever.
/// The delete bug was already real — it was invisible only because no screen
/// called delete.
///
/// So the projections are derived here instead, from whatever records remain,
/// and every repository calls this after add, update and delete alike. For an
/// add the result is identical to the old projection (the newest record after
/// an add is the one just added), which is what makes it safe to adopt.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

class AnimalProjectionRecalculator {
  const AnimalProjectionRecalculator._();

  /// Recomputes every record-derived field on [animalUuid] and saves it.
  ///
  /// Must run inside a write transaction — every caller is already in one.
  static Future<void> recalculate(Isar isar, String animalUuid) async {
    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(animalUuid)
        .findFirst();
    if (animal == null) return;

    await _applyWeight(isar, animal, animalUuid);
    await _applyBodyCondition(isar, animal, animalUuid);
    await _applyLocation(isar, animal, animalUuid);
    await _applyHealthFlags(isar, animal, animalUuid);
    await _applyHerdStatus(isar, animal, animalUuid);

    animal
      ..lastUpdateDate = DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(animal);
  }

  /// Current weight is the most recent weighing.
  ///
  /// With no weighings left the field is *kept*, not cleared: an animal's
  /// weight can also be typed at registration, and that figure is not
  /// recoverable from the record set.
  static Future<void> _applyWeight(
    Isar isar,
    IsarAnimal animal,
    String animalUuid,
  ) async {
    final latest = await isar.isarWeightRecords
        .where()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findFirst();
    if (latest != null) animal.weight = latest.weight;
  }

  /// Body condition is the most recent scoring. Kept when none remain, for the
  /// same reason as the weight.
  static Future<void> _applyBodyCondition(
    Isar isar,
    IsarAnimal animal,
    String animalUuid,
  ) async {
    final scored =
        await isar.isarProductionRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .filter()
            .typeEqualTo(ProductionRecordType.bodyConditionScore.name)
            .sortByDateDesc()
            .findAll();
    for (final record in scored) {
      if (record.score != null) {
        animal.bodyConditionScore = record.score;
        return;
      }
    }
  }

  /// Where the animal stands is the destination of its most recent movement.
  /// Kept when none remain: registration also places an animal.
  static Future<void> _applyLocation(
    Isar isar,
    IsarAnimal animal,
    String animalUuid,
  ) async {
    final latest = await isar.isarMovementRecords
        .where()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findFirst();
    if (latest == null) return;

    final destination =
        await isar.isarLocations
            .where()
            .uuidEqualTo(latest.toLocation)
            .findFirst() ??
        await isar.isarLocations
            .filter()
            .nameEqualTo(latest.toLocation)
            .findFirst();

    animal
      ..currentLocationId = destination?.uuid
      ..lastMovementDate = latest.date;
  }

  /// The health flags answer "has this ever been done", so each one is simply
  /// whether a record of that kind still exists. They used to latch on and
  /// never clear, which meant correcting a vaccine record to a treatment left
  /// the animal marked vaccinated for good.
  static Future<void> _applyHealthFlags(
    Isar isar,
    IsarAnimal animal,
    String animalUuid,
  ) async {
    final records = await isar.isarHealthRecords
        .where()
        .animalUuidEqualTo(animalUuid)
        .findAll();

    final types = records.map((record) => record.type).toSet();
    animal
      ..vaccinated = types.contains(HealthRecordType.vaccine.name)
      ..dewormed = types.contains(HealthRecordType.deworming.name)
      ..hasVitamins = types.contains(HealthRecordType.vitamins.name);

    final hasDisease = types.contains(HealthRecordType.disease.name);
    if (hasDisease) {
      animal
        ..underObservation = true
        ..requiresAttention = true;
    }
  }

  /// Whether the animal is still in the herd.
  ///
  /// Both a death record and a sale/write-off take it out, so the answer is the
  /// most recent of the two collections. With neither left the animal is back
  /// in the herd — that is the point: undoing a mistaken sale used to be
  /// impossible from the record screens.
  ///
  /// [AnimalStatus.archived] is deliberately untouched. That is the directory's
  /// own soft delete, not something a record decides.
  static Future<void> _applyHerdStatus(
    Isar isar,
    IsarAnimal animal,
    String animalUuid,
  ) async {
    if (animal.status == AnimalStatus.archived.name) return;

    final health = await isar.isarHealthRecords
        .where()
        .animalUuidEqualTo(animalUuid)
        .filter()
        .typeEqualTo(HealthRecordType.death.name)
        .sortByDateDesc()
        .findFirst();

    final commercial =
        await isar.isarCommercialRecords
            .where()
            .animalUuidEqualTo(animalUuid)
            .sortByDateDesc()
            .findAll();
    IsarCommercialRecord? leaving;
    for (final record in commercial) {
      if (_statusFor(record.type) != null) {
        leaving = record;
        break;
      }
    }

    if (health == null && leaving == null) {
      animal.status = AnimalStatus.active.name;
      return;
    }

    // An animal that has left the herd is nobody's pending job any more.
    animal
      ..underObservation = false
      ..requiresAttention = false;

    if (leaving == null) {
      animal.status = AnimalStatus.dead.name;
      return;
    }
    if (health == null) {
      animal.status = _statusFor(leaving.type)!.name;
      return;
    }
    animal.status = health.date.isAfter(leaving.date)
        ? AnimalStatus.dead.name
        : _statusFor(leaving.type)!.name;
  }

  static AnimalStatus? _statusFor(String rawType) {
    final type = CommercialRecordType.values
        .where((value) => value.name == rawType)
        .firstOrNull;
    switch (type) {
      case CommercialRecordType.sale:
      case CommercialRecordType.writeOffSale:
        return AnimalStatus.sold;
      case CommercialRecordType.writeOffDeath:
        return AnimalStatus.dead;
      case CommercialRecordType.purchase:
      case CommercialRecordType.ownershipChange:
      case CommercialRecordType.priceUpdate:
      case null:
        return null;
    }
  }
}
