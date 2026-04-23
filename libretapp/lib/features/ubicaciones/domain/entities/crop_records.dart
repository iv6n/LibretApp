import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';

String _generateId() =>
    'crop-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

class CropRecord extends Equatable {
  CropRecord({
    String? uuid,
    required this.cropName,
    this.variety = '',
    required this.plantingDate,
    this.expectedHarvestDate,
    this.growthStage = CropGrowthStage.planted,
    this.wateringFrequencyDays = 3,
    this.lastWateredDate,
    this.status = CropStatus.active,
    this.surface = 0,
    this.notes,
    this.harvests = const [],
    this.waterings = const [],
    this.healthRecords = const [],
    this.tasks = const [],
  }) : uuid = uuid ?? _generateId();

  final String uuid;
  final String cropName;
  final String variety;
  final DateTime plantingDate;
  final DateTime? expectedHarvestDate;
  final CropGrowthStage growthStage;
  final int wateringFrequencyDays;
  final DateTime? lastWateredDate;
  final CropStatus status;
  final Area surface;
  final String? notes;
  final List<HarvestRecord> harvests;
  final List<CropWateringRecord> waterings;
  final List<CropHealthRecord> healthRecords;
  final List<CropTask> tasks;

  DateTime? get nextWateringDate {
    if (lastWateredDate == null) return null;
    return lastWateredDate!.add(Duration(days: wateringFrequencyDays));
  }

  bool get isOverdueForWatering {
    final next = nextWateringDate;
    if (next == null) return lastWateredDate == null;
    return DateTime.now().isAfter(next);
  }

  int? get daysUntilHarvest {
    if (expectedHarvestDate == null) return null;
    return expectedHarvestDate!.difference(DateTime.now()).inDays;
  }

  double get totalYieldKg => harvests.fold(0.0, (sum, h) => sum + h.yieldKg);

  CropRecord copyWith({
    String? uuid,
    String? cropName,
    String? variety,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    CropGrowthStage? growthStage,
    int? wateringFrequencyDays,
    DateTime? lastWateredDate,
    CropStatus? status,
    Area? surface,
    String? notes,
    List<HarvestRecord>? harvests,
    List<CropWateringRecord>? waterings,
    List<CropHealthRecord>? healthRecords,
    List<CropTask>? tasks,
  }) {
    return CropRecord(
      uuid: uuid ?? this.uuid,
      cropName: cropName ?? this.cropName,
      variety: variety ?? this.variety,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      growthStage: growthStage ?? this.growthStage,
      wateringFrequencyDays:
          wateringFrequencyDays ?? this.wateringFrequencyDays,
      lastWateredDate: lastWateredDate ?? this.lastWateredDate,
      status: status ?? this.status,
      surface: surface ?? this.surface,
      notes: notes ?? this.notes,
      harvests: harvests ?? this.harvests,
      waterings: waterings ?? this.waterings,
      healthRecords: healthRecords ?? this.healthRecords,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    cropName,
    variety,
    plantingDate,
    expectedHarvestDate,
    growthStage,
    wateringFrequencyDays,
    lastWateredDate,
    status,
    surface,
    notes,
    harvests,
    waterings,
    healthRecords,
    tasks,
  ];
}

class HarvestRecord extends Equatable {
  const HarvestRecord({
    required this.date,
    required this.yieldKg,
    this.qualityRating = 3,
    this.notes,
  });
  final DateTime date;
  final double yieldKg;
  final int qualityRating; // 1-5
  final String? notes;

  @override
  List<Object?> get props => [date, yieldKg, qualityRating, notes];
}

class CropWateringRecord extends Equatable {
  const CropWateringRecord({
    required this.date,
    this.amountLiters = 0,
    this.method = 'manual',
    this.notes,
  });
  final DateTime date;
  final double amountLiters;
  final String method; // manual, goteo, aspersión
  final String? notes;

  @override
  List<Object?> get props => [date, amountLiters, method, notes];
}

class CropHealthRecord extends Equatable {
  const CropHealthRecord({
    required this.date,
    required this.issue,
    this.treatment = '',
    this.severity = 'media',
    this.notes,
  });
  final DateTime date;
  final String issue; // plaga, enfermedad, deficiencia
  final String treatment;
  final String severity; // baja, media, alta
  final String? notes;

  @override
  List<Object?> get props => [date, issue, treatment, severity, notes];
}

class CropTask extends Equatable {
  CropTask({
    String? uuid,
    required this.type,
    required this.dueDate,
    this.completed = false,
    this.notes,
  }) : uuid = uuid ?? _generateId();

  final String uuid;
  final CropTaskType type;
  final DateTime dueDate;
  final bool completed;
  final String? notes;

  bool get isOverdue => !completed && DateTime.now().isAfter(dueDate);

  CropTask copyWith({
    String? uuid,
    CropTaskType? type,
    DateTime? dueDate,
    bool? completed,
    String? notes,
  }) {
    return CropTask(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [uuid, type, dueDate, completed, notes];
}
