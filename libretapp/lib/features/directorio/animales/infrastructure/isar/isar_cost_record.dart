/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_cost_record \u2014 Isar schema for CostRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';

part 'isar_cost_record.g.dart';

@collection
class IsarCostRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String animalUuid;

  late DateTime date;
  late String type;
  late double amount;
  String? currency;
  String? notes;
}

extension IsarCostRecordMapper on IsarCostRecord {
  CostRecord toEntity() {
    return CostRecord(
      id: id.toString(),
      date: date,
      type: CostType.values.byName(type),
      amount: amount,
      currency: currency,
      notes: notes,
    );
  }
}

extension CostRecordToIsar on CostRecord {
  IsarCostRecord toIsar(String animalUuid) {
    final model = IsarCostRecord()
      ..animalUuid = animalUuid
      ..date = date
      ..type = type.name
      ..amount = amount
      ..currency = currency
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
