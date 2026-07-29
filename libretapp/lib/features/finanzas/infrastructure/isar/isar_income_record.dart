/// features \u203a finanzas \u203a infrastructure \u203a isar \u203a isar_income_record \u2014 Isar schema for IncomeRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';

part 'isar_income_record.g.dart';

@collection
class IsarIncomeRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late String type;
  late double amount;
  String? currency;
  String? animalUuid;
  String? notes;
}

extension IsarIncomeRecordMapper on IsarIncomeRecord {
  IncomeRecord toEntity() {
    return IncomeRecord(
      id: id.toString(),
      date: date,
      type: IncomeType.values.byName(type),
      amount: amount,
      currency: currency,
      animalUuid: animalUuid,
      notes: notes,
    );
  }
}

extension IncomeRecordToIsar on IncomeRecord {
  IsarIncomeRecord toIsar() {
    final model = IsarIncomeRecord()
      ..date = date
      ..type = type.name
      ..amount = amount
      ..currency = currency
      ..animalUuid = animalUuid
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
