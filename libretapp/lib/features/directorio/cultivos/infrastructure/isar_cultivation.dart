/// Isar persistence model for independent cultivations.
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

part 'isar_cultivation.g.dart';

@collection
class IsarCultivation {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  late String variety;
  late String scale;

  @Index()
  String? locationUuid;

  late DateTime plantingDate;
  DateTime? expectedHarvestDate;
  late String growthStage;
  late int wateringFrequencyDays;
  DateTime? lastWateredDate;

  @Index()
  late String status;

  late int quantity;
  late double areaSquareMeters;
  late String preferredAreaUnit;
  String? notes;
  List<IsarHarvestRecord> harvests = [];
  List<IsarCropWateringRecord> waterings = [];
  List<IsarCropHealthRecord> healthRecords = [];
  List<IsarCropTask> tasks = [];
  late DateTime createdAt;
  late DateTime updatedAt;

  CultivationEntity toEntity() => CultivationEntity(
    uuid: uuid,
    name: name,
    variety: variety,
    scale: _enumByName(CultivationScale.values, scale),
    locationUuid: locationUuid,
    plantingDate: plantingDate,
    expectedHarvestDate: expectedHarvestDate,
    growthStage: _enumByName(CropGrowthStage.values, growthStage),
    wateringFrequencyDays: wateringFrequencyDays,
    lastWateredDate: lastWateredDate,
    status: _enumByName(CropStatus.values, status),
    quantity: quantity,
    areaSquareMeters: areaSquareMeters,
    preferredAreaUnit: _enumByName(
      CultivationAreaUnit.values,
      preferredAreaUnit,
    ),
    notes: notes,
    harvests: harvests.map((record) => record.toEntity()).toList(),
    waterings: waterings.map((record) => record.toEntity()).toList(),
    healthRecords: healthRecords.map((record) => record.toEntity()).toList(),
    tasks: tasks.map((record) => record.toEntity()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static IsarCultivation fromEntity(CultivationEntity entity) =>
      IsarCultivation()
        ..uuid = entity.uuid
        ..name = entity.name
        ..variety = entity.variety
        ..scale = entity.scale.name
        ..locationUuid = entity.locationUuid
        ..plantingDate = entity.plantingDate
        ..expectedHarvestDate = entity.expectedHarvestDate
        ..growthStage = entity.growthStage.name
        ..wateringFrequencyDays = entity.wateringFrequencyDays
        ..lastWateredDate = entity.lastWateredDate
        ..status = entity.status.name
        ..quantity = entity.quantity
        ..areaSquareMeters = entity.areaSquareMeters
        ..preferredAreaUnit = entity.preferredAreaUnit.name
        ..notes = entity.notes
        ..harvests = entity.harvests.map(IsarHarvestRecord.fromEntity).toList()
        ..waterings = entity.waterings
            .map(IsarCropWateringRecord.fromEntity)
            .toList()
        ..healthRecords = entity.healthRecords
            .map(IsarCropHealthRecord.fromEntity)
            .toList()
        ..tasks = entity.tasks.map(IsarCropTask.fromEntity).toList()
        ..createdAt = entity.createdAt
        ..updatedAt = entity.updatedAt;
}

T _enumByName<T extends Enum>(List<T> values, String name) => values.firstWhere(
  (value) => value.name == name,
  orElse: () => values.first,
);
