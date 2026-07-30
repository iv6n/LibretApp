/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_weight_record \u2014 Isar schema for WeightRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

part 'isar_weight_record.g.dart';

@collection
class IsarWeightRecord implements StableRecordModel {
  @override
  Id id = Isar.autoIncrement;

  @override
  @Index(unique: true, replace: true)
  String recordUuid = '';

  @Index()
  late String animalUuid;

  late DateTime date;
  late double weight;
  late String method;
  String? measuredBy;
  String? notes;
}

extension IsarWeightRecordMapper on IsarWeightRecord {
  WeightRecord toEntity() {
    return WeightRecord(
      id: id.toString(),
      date: date,
      weight: weight,
      method: WeightMethod.values.byName(method),
      measuredBy: measuredBy,
      notes: notes,
    );
  }
}

extension WeightRecordToIsar on WeightRecord {
  IsarWeightRecord toIsar(String animalUuid) {
    final model = IsarWeightRecord()
      ..animalUuid = animalUuid
      ..date = date
      ..weight = weight
      ..method = method.name
      ..measuredBy = measuredBy
      ..notes = notes;

    if (id != null) {
      final parsed = int.tryParse(id!);
      if (parsed != null) {
        model.id = parsed;
      }
    }
    return model;
  }
}
