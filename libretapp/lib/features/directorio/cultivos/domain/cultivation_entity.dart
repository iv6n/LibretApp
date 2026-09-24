/// Domain model for a plant, garden group, or field-scale cultivation.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:uuid/uuid.dart';

enum CultivationScale { individual, group, area }

extension CultivationScaleX on CultivationScale {
  String get displayName => switch (this) {
    CultivationScale.individual => 'Planta individual',
    CultivationScale.group => 'Grupo o huerto',
    CultivationScale.area => 'Siembra por superficie',
  };
}

enum CultivationAreaUnit { squareMeters, hectares }

extension CultivationAreaUnitX on CultivationAreaUnit {
  String get displayName => switch (this) {
    CultivationAreaUnit.squareMeters => 'm²',
    CultivationAreaUnit.hectares => 'ha',
  };

  double toSquareMeters(double value) => switch (this) {
    CultivationAreaUnit.squareMeters => value,
    CultivationAreaUnit.hectares => value * 10000,
  };

  double fromSquareMeters(double value) => switch (this) {
    CultivationAreaUnit.squareMeters => value,
    CultivationAreaUnit.hectares => value / 10000,
  };
}

const _unset = Object();

class CultivationEntity extends Equatable {
  CultivationEntity({
    String? uuid,
    required this.name,
    this.variety = '',
    this.scale = CultivationScale.individual,
    this.locationUuid,
    required this.plantingDate,
    this.expectedHarvestDate,
    this.growthStage = CropGrowthStage.planted,
    this.wateringFrequencyDays = 3,
    this.lastWateredDate,
    this.status = CropStatus.active,
    this.quantity = 1,
    this.areaSquareMeters = 0,
    this.preferredAreaUnit = CultivationAreaUnit.squareMeters,
    this.notes,
    this.harvests = const [],
    this.waterings = const [],
    this.healthRecords = const [],
    this.tasks = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : uuid = uuid ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String uuid;
  final String name;
  final String variety;
  final CultivationScale scale;
  final String? locationUuid;
  final DateTime plantingDate;
  final DateTime? expectedHarvestDate;
  final CropGrowthStage growthStage;
  final int wateringFrequencyDays;
  final DateTime? lastWateredDate;
  final CropStatus status;
  final int quantity;
  final double areaSquareMeters;
  final CultivationAreaUnit preferredAreaUnit;
  final String? notes;
  final List<HarvestRecord> harvests;
  final List<CropWateringRecord> waterings;
  final List<CropHealthRecord> healthRecords;
  final List<CropTask> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == CropStatus.active;

  DateTime get nextWateringDate => (lastWateredDate ?? plantingDate).add(
    Duration(days: wateringFrequencyDays),
  );

  bool get isOverdueForWatering =>
      isActive && DateTime.now().isAfter(nextWateringDate);

  int? get daysUntilHarvest =>
      expectedHarvestDate?.difference(DateTime.now()).inDays;

  double get totalYieldKg =>
      harvests.fold(0, (total, record) => total + record.yieldKg);

  double get displayArea =>
      preferredAreaUnit.fromSquareMeters(areaSquareMeters);

  String get measureLabel => switch (scale) {
    CultivationScale.individual => '1 planta',
    CultivationScale.group => '$quantity plantas',
    CultivationScale.area =>
      '${_formatNumber(displayArea)} ${preferredAreaUnit.displayName}',
  };

  factory CultivationEntity.fromLegacyCrop({
    required CropRecord crop,
    required String locationUuid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CultivationEntity(
      uuid: crop.uuid,
      name: crop.cropName,
      variety: crop.variety,
      scale: CultivationScale.area,
      locationUuid: locationUuid,
      plantingDate: crop.plantingDate,
      expectedHarvestDate: crop.expectedHarvestDate,
      growthStage: crop.growthStage,
      wateringFrequencyDays: crop.wateringFrequencyDays,
      lastWateredDate: crop.lastWateredDate,
      status: crop.status,
      quantity: 1,
      areaSquareMeters: crop.surface * 10000,
      preferredAreaUnit: CultivationAreaUnit.hectares,
      notes: crop.notes,
      harvests: crop.harvests,
      waterings: crop.waterings,
      healthRecords: crop.healthRecords,
      tasks: crop.tasks,
      createdAt: createdAt ?? crop.plantingDate,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  CropRecord toLegacyCrop() => CropRecord(
    uuid: uuid,
    cropName: name,
    variety: variety,
    plantingDate: plantingDate,
    expectedHarvestDate: expectedHarvestDate,
    growthStage: growthStage,
    wateringFrequencyDays: wateringFrequencyDays,
    lastWateredDate: lastWateredDate,
    status: status,
    surface: areaSquareMeters / 10000,
    notes: notes,
    harvests: harvests,
    waterings: waterings,
    healthRecords: healthRecords,
    tasks: tasks,
  );

  CultivationEntity copyWith({
    String? uuid,
    String? name,
    String? variety,
    CultivationScale? scale,
    Object? locationUuid = _unset,
    DateTime? plantingDate,
    Object? expectedHarvestDate = _unset,
    CropGrowthStage? growthStage,
    int? wateringFrequencyDays,
    Object? lastWateredDate = _unset,
    CropStatus? status,
    int? quantity,
    double? areaSquareMeters,
    CultivationAreaUnit? preferredAreaUnit,
    Object? notes = _unset,
    List<HarvestRecord>? harvests,
    List<CropWateringRecord>? waterings,
    List<CropHealthRecord>? healthRecords,
    List<CropTask>? tasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CultivationEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      scale: scale ?? this.scale,
      locationUuid: identical(locationUuid, _unset)
          ? this.locationUuid
          : locationUuid as String?,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: identical(expectedHarvestDate, _unset)
          ? this.expectedHarvestDate
          : expectedHarvestDate as DateTime?,
      growthStage: growthStage ?? this.growthStage,
      wateringFrequencyDays:
          wateringFrequencyDays ?? this.wateringFrequencyDays,
      lastWateredDate: identical(lastWateredDate, _unset)
          ? this.lastWateredDate
          : lastWateredDate as DateTime?,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
      preferredAreaUnit: preferredAreaUnit ?? this.preferredAreaUnit,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      harvests: harvests ?? this.harvests,
      waterings: waterings ?? this.waterings,
      healthRecords: healthRecords ?? this.healthRecords,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    name,
    variety,
    scale,
    locationUuid,
    plantingDate,
    expectedHarvestDate,
    growthStage,
    wateringFrequencyDays,
    lastWateredDate,
    status,
    quantity,
    areaSquareMeters,
    preferredAreaUnit,
    notes,
    harvests,
    waterings,
    healthRecords,
    tasks,
    createdAt,
    updatedAt,
  ];
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value
      .toStringAsFixed(value < 10 ? 2 : 1)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
