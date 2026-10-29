library;

import 'package:isar_community/isar.dart';
import '../../domain/entities/weaning_record.dart';
import '../../domain/entities/weight_record.dart';

part 'isar_weaning_record.g.dart';

@collection
class IsarWeaningRecord {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String recordUuid;
  @Index()
  late String animalUuid;
  late DateTime date;
  double? weightKg;
  String weightMethod = 'scale';
  String? weightRecordUuid;
  String? performedBy;
  String? notes;
  DateTime? updatedAt;
  String? previousProductionStage;
  String? previousCategory;

  @ignore
  WeaningRecord get entity => WeaningRecord(
    id: id.toString(), recordUuid: recordUuid, animalUuid: animalUuid,
    date: date, weightKg: weightKg,
    weightMethod: weightMethod == 'estimated' ? WeightMethod.estimated : WeightMethod.scale,
    weightRecordUuid: weightRecordUuid, performedBy: performedBy,
    notes: notes, updatedAt: updatedAt,
  );
}
