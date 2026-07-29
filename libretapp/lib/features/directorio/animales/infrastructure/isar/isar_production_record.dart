/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_production_record \u2014 Isar schema for ProductionRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/sync/sync_fields.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';

part 'isar_production_record.g.dart';

@collection
class IsarProductionRecord implements AnimalRecordSyncFields {
  Id id = Isar.autoIncrement;

  @Index()
  late String animalUuid;

  late DateTime date;
  late String type;
  double? value;
  String? unit;
  int? score;
  String? notes;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  DateTime? updatedAt;
  late bool synced = false;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;
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
