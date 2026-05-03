import 'package:isar/isar.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';

part 'isar_general_expense_record.g.dart';

@collection
class IsarGeneralExpenseRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late String type;
  late double amount;
  String? currency;
  String? notes;
}

extension IsarGeneralExpenseRecordMapper on IsarGeneralExpenseRecord {
  GeneralExpenseRecord toEntity() {
    return GeneralExpenseRecord(
      id: id.toString(),
      date: date,
      type: GeneralExpenseType.values.byName(type),
      amount: amount,
      currency: currency,
      notes: notes,
    );
  }
}

extension GeneralExpenseRecordToIsar on GeneralExpenseRecord {
  IsarGeneralExpenseRecord toIsar() {
    final model = IsarGeneralExpenseRecord()
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
