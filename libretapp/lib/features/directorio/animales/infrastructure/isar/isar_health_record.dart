/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_health_record \u2014 Isar schema for HealthRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';

part 'isar_health_record.g.dart';

@collection
class IsarHealthRecord implements StableRecordModel {
  @override
  Id id = Isar.autoIncrement;

  @override
  @Index(unique: true, replace: true)
  String recordUuid = '';

  @Index()
  late String animalUuid;

  late DateTime date;
  late String type;
  late String product;
  String? dose;
  String? appliedBy;
  String? notes;
  DateTime? nextDueDate;
  String? cause;
  String? medicineBatch;
  int? withdrawalDays;
  DateTime? withdrawalEndDate;
}

extension IsarHealthRecordMapper on IsarHealthRecord {
  HealthRecord toEntity() {
    return HealthRecord(
      id: id.toString(),
      date: date,
      type: HealthRecordType.values.byName(type),
      product: product,
      dose: dose,
      appliedBy: appliedBy,
      notes: notes,
      nextDueDate: nextDueDate,
      cause: cause,
      medicineBatch: medicineBatch,
      withdrawalDays: withdrawalDays,
      withdrawalEndDate: withdrawalEndDate,
    );
  }
}

extension HealthRecordToIsar on HealthRecord {
  IsarHealthRecord toIsar(String animalUuid) {
    final model = IsarHealthRecord()
      ..animalUuid = animalUuid
      ..date = date
      ..type = type.name
      ..product = product
      ..dose = dose
      ..appliedBy = appliedBy
      ..notes = notes
      ..nextDueDate = nextDueDate
      ..cause = cause;
    model
      ..medicineBatch = medicineBatch
      ..withdrawalDays = withdrawalDays
      ..withdrawalEndDate = withdrawalEndDate;

    if (id != null) {
      final parsed = int.tryParse(id!);
      if (parsed != null) {
        model.id = parsed;
      }
    }
    return model;
  }
}
