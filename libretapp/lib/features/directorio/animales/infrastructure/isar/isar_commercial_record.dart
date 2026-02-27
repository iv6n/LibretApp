import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';

part 'isar_commercial_record.g.dart';

@collection
class IsarCommercialRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String animalUuid;

  late DateTime date;
  late String type;
  double? amount;
  String? currency;
  String? counterparty;
  String? notes;
}

extension IsarCommercialRecordMapper on IsarCommercialRecord {
  CommercialRecord toEntity() {
    return CommercialRecord(
      id: id.toString(),
      date: date,
      type: CommercialRecordType.values.byName(type),
      amount: amount,
      currency: currency,
      counterparty: counterparty,
      notes: notes,
    );
  }
}

extension CommercialRecordToIsar on CommercialRecord {
  IsarCommercialRecord toIsar(String animalUuid) {
    final model = IsarCommercialRecord()
      ..animalUuid = animalUuid
      ..date = date
      ..type = type.name
      ..amount = amount
      ..currency = currency
      ..counterparty = counterparty
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
