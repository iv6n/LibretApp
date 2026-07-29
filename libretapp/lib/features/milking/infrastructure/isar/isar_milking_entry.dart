library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';

part 'isar_milking_entry.g.dart';

@collection
class IsarMilkingEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(composite: [CompositeIndex('animalUuid')], unique: true)
  late String sessionUuid;

  @Index()
  late String animalUuid;

  late int volumeMilliliters;
  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;
}

extension IsarMilkingEntryMapper on IsarMilkingEntry {
  MilkingEntry toEntity() => MilkingEntry(
    uuid: uuid,
    sessionUuid: sessionUuid,
    animalUuid: animalUuid,
    volumeMilliliters: volumeMilliliters,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension MilkingEntryToIsar on MilkingEntry {
  IsarMilkingEntry toIsar() => IsarMilkingEntry()
    ..uuid = uuid
    ..sessionUuid = sessionUuid
    ..animalUuid = animalUuid
    ..volumeMilliliters = volumeMilliliters
    ..notes = notes
    ..createdAt = createdAt
    ..updatedAt = updatedAt;
}
