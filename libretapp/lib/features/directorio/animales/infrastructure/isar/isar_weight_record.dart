/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_weight_record \u2014 Isar schema for WeightRecord.
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

part 'isar_weight_record.g.dart';

@collection
class IsarWeightRecord implements StableAnimalRecordModel {
  @override
  Id id = Isar.autoIncrement;

  @override
  @Index(unique: true, replace: true)
  String recordUuid = '';

  @Index()
  @override
  late String animalUuid;

  @Index()
  String? lotUuid;

  late DateTime date;
  late double weight;
  late String method;
  String? measuredBy;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;
}

extension IsarWeightRecordMapper on IsarWeightRecord {
  WeightRecord toEntity() {
    return WeightRecord(
      id: id.toString(),
      animalUuid: animalUuid,
      lotUuid: lotUuid,
      date: date,
      weight: weight,
      method: WeightMethod.values.byName(method),
      measuredBy: measuredBy,
      notes: notes,
      recordUuid: recordUuid,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension WeightRecordToIsar on WeightRecord {
  IsarWeightRecord toIsar(String animalUuid) {
    final now = DateTime.now();
    final model = IsarWeightRecord()
      ..animalUuid = animalUuid
      ..lotUuid = lotUuid
      ..date = date
      ..weight = weight
      ..method = method.name
      ..measuredBy = measuredBy
      ..notes = notes
      ..createdAt = createdAt ?? now
      ..updatedAt = updatedAt ?? now;

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
