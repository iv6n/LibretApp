/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_reproduction_record \u2014 Isar schema for ReproductionRecord.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

part 'isar_reproduction_record.g.dart';

@collection
class IsarReproductionRecord implements StableRecordModel {
  @override
  Id id = Isar.autoIncrement;

  @override
  @Index(unique: true, replace: true)
  String recordUuid = '';

  @Index()
  late String animalUuid;

  late DateTime serviceDate;
  late String serviceType;

  /// Indexed so a bull's service history can be derived from the cow-side
  /// records instead of duplicating a row on his side.
  @Index()
  String? maleSireUuid;

  String? maleSireIdentifier;
  DateTime? pregnancyCheckDate;
  String? pregnancyResult;
  DateTime? expectedCalvingDate;
  DateTime? actualCalvingDate;
  String? calvingOutcome;
  int? calvingEase;
  List<String> offspringUuids = [];

  /// Free-text calving notes. Kept under the legacy physical column name
  /// `calvingResult`, which was the only calving field before
  /// [calvingOutcome] existed — renaming it would make Isar drop the column
  /// and silently discard every note captured so far.
  @Name('calvingResult')
  String? calvingNotes;

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
      calvingOutcome: calvingOutcome != null
          ? CalvingOutcome.values.byName(calvingOutcome!)
          : null,
      calvingEase: calvingEase,
      offspringUuids: List<String>.from(offspringUuids),
      calvingNotes: calvingNotes,
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
      ..calvingOutcome = calvingOutcome?.name
      ..calvingEase = calvingEase
      ..offspringUuids = List<String>.from(offspringUuids)
      ..calvingNotes = calvingNotes
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
