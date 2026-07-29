/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_reproduction_record \u2014 Isar schema for ReproductionRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

part 'isar_reproduction_record.g.dart';

@collection
class IsarReproductionRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String animalUuid;

  late DateTime serviceDate;
  late String serviceType;
  String? maleSireUuid;
  String? maleSireIdentifier;
  DateTime? pregnancyCheckDate;
  String? pregnancyResult;
  DateTime? expectedCalvingDate;
  DateTime? actualCalvingDate;
  String? calvingResult;
  String? notes;
  String? servicedBy;
}

extension IsarReproductionRecordMapper on IsarReproductionRecord {
  ReproductionRecord toEntity() {
    return ReproductionRecord(
      id: id.toString(),
      serviceDate: serviceDate,
      serviceType: ServiceType.values.byName(serviceType),
      maleSireUuid: maleSireUuid,
      maleSireIdentifier: maleSireIdentifier,
      pregnancyCheckDate: pregnancyCheckDate,
      pregnancyResult: pregnancyResult != null
          ? PregnancyCheckResult.values.byName(pregnancyResult!)
          : null,
      expectedCalvingDate: expectedCalvingDate,
      actualCalvingDate: actualCalvingDate,
      calvingResult: calvingResult,
      notes: notes,
      servicedBy: servicedBy,
    );
  }
}

extension ReproductionRecordToIsar on ReproductionRecord {
  IsarReproductionRecord toIsar(String animalUuid) {
    final model = IsarReproductionRecord()
      ..animalUuid = animalUuid
      ..serviceDate = serviceDate
      ..serviceType = serviceType.name
      ..maleSireUuid = maleSireUuid
      ..maleSireIdentifier = maleSireIdentifier
      ..pregnancyCheckDate = pregnancyCheckDate
      ..pregnancyResult = pregnancyResult?.name
      ..expectedCalvingDate = expectedCalvingDate
      ..actualCalvingDate = actualCalvingDate
      ..calvingResult = calvingResult
      ..notes = notes
      ..servicedBy = servicedBy;

    if (id != null) {
      final parsed = int.tryParse(id!);
      if (parsed != null) {
        model.id = parsed;
      }
    }
    return model;
  }
}
