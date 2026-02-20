import 'package:isar/isar.dart';
import 'package:libretapp/features/animales/domain/entities/health_record.dart';

part 'isar_health_record.g.dart';

@collection
class IsarHealthRecord {
  Id id = Isar.autoIncrement;

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

    if (id != null) {
      final parsed = int.tryParse(id!);
      if (parsed != null) {
        model.id = parsed;
      }
    }
    return model;
  }
}
