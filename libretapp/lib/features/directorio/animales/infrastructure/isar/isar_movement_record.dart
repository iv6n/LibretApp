/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_movement_record \u2014 Isar schema for MovementRecord.
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';

part 'isar_movement_record.g.dart';

@collection
class IsarMovementRecord implements StableAnimalRecordModel {
  @override
  Id id = Isar.autoIncrement;

  @override
  @Index(unique: true, replace: true)
  String recordUuid = '';

  @Index()
  @override
  late String animalUuid;

  String? fromLocation;
  late String toLocation;
  bool clearsLocation = false;
  late DateTime date;
  late String reason;
  String? notes;
  String? movedBy;
  DateTime? updatedAt;
  double? latitude;
  double? longitude;
  double? accuracyMeters;
}

extension IsarMovementRecordMapper on IsarMovementRecord {
  MovementRecord toEntity() {
    return MovementRecord(
      id: id.toString(),
      fromLocation: fromLocation,
      toLocation: toLocation,
      clearsLocation: clearsLocation,
      date: date,
      reason: MovementReason.values.byName(reason),
      notes: notes,
      movedBy: movedBy,
      recordUuid: recordUuid,
      updatedAt: updatedAt,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
    );
  }
}

extension MovementRecordToIsar on MovementRecord {
  IsarMovementRecord toIsar(String animalUuid) {
    final model = IsarMovementRecord()
      ..animalUuid = animalUuid
      ..fromLocation = fromLocation
      ..toLocation = toLocation
      ..clearsLocation = clearsLocation
      ..date = date
      ..reason = reason.name
      ..notes = notes
      ..movedBy = movedBy
      ..updatedAt = DateTime.now()
      ..latitude = latitude
      ..longitude = longitude
      ..accuracyMeters = accuracyMeters;

    if (recordUuid?.isNotEmpty == true) model.recordUuid = recordUuid!;

    if (id != null) {
      final parsed = int.tryParse(id!);
      if (parsed != null) {
        model.id = parsed;
      }
    }
    return model;
  }
}
