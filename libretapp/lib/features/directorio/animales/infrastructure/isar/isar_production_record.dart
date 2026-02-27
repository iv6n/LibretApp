import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';

part 'isar_production_record.g.dart';

@collection
class IsarProductionRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String animalUuid;

  late DateTime date;
  late String type;
  double? value;
  String? unit;
  int? score;
  String? notes;
}

extension IsarProductionRecordMapper on IsarProductionRecord {
  ProductionRecord toEntity() {
    return ProductionRecord(
      id: id.toString(),
      date: date,
      type: ProductionRecordType.values.byName(type),
      value: value,
      unit: unit,
      score: score,
      notes: notes,
    );
  }
}

extension ProductionRecordToIsar on ProductionRecord {
  IsarProductionRecord toIsar(String animalUuid) {
    final model = IsarProductionRecord()
      ..animalUuid = animalUuid
      ..date = date
      ..type = type.name
      ..value = value
      ..unit = unit
      ..score = score
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
