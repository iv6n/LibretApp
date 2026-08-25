/// Shared operational-planning vocabulary for animals, land, crops and
/// locations. The persisted compatibility model is [AgendaEntry].
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

enum WorkTargetType { animal, lote, location, crop }

class WorkTargetRef extends Equatable {
  const WorkTargetRef({required this.type, required this.id});

  final WorkTargetType type;
  final String id;

  Map<String, dynamic> toJson() => {'type': type.name, 'id': id};

  factory WorkTargetRef.fromJson(Map<String, dynamic> json) => WorkTargetRef(
    type: WorkTargetType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => WorkTargetType.location,
    ),
    id: json['id'] as String,
  );

  @override
  List<Object?> get props => [type, id];
}

enum WorkActionType {
  recordHealth,
  recordCare,
  reproductionCheck,
  calving,
  weight,
  movement,
  cropWater,
  cropTask,
  harvest,
  landWork,
  locationInspection,
  maintenance,
  generic,
}

enum WorkSourceType {
  manual,
  health,
  care,
  reproduction,
  cropTask,
  cropCycle,
  locationPlan,
}

/// A reusable rule for recurring work. It is intentionally independent of
/// persistence so a future Isar collection can be introduced without
/// changing the occurrence contract.
class WorkPlan extends Equatable {
  const WorkPlan({
    required this.id,
    required this.title,
    required this.action,
    required this.category,
    required this.nextDate,
    this.targets = const [],
    this.locationUuid,
    this.recurrenceRule,
    this.intervalDays,
    this.remindLeadDays = 0,
    this.assigneeId,
    this.workTeamId,
    this.priority = AgendaPrioridad.normal,
    this.checklist = const [],
    this.active = true,
  });

  final String id;
  final String title;
  final WorkActionType action;
  final String category;
  final DateTime nextDate;
  final List<WorkTargetRef> targets;
  final String? locationUuid;
  final String? recurrenceRule;
  final int? intervalDays;
  final int remindLeadDays;
  final String? assigneeId;
  final String? workTeamId;
  final String priority;
  final List<AgendaChecklistItem> checklist;
  final bool active;

  @override
  List<Object?> get props => [
    id,
    title,
    action,
    category,
    nextDate,
    targets,
    locationUuid,
    recurrenceRule,
    intervalDays,
    remindLeadDays,
    assigneeId,
    workTeamId,
    priority,
    checklist,
    active,
  ];
}

/// Compatibility alias while screens are migrated from AgendaEntry naming.
typedef WorkOccurrence = AgendaEntry;

extension WorkActionCodec on WorkActionType {
  String get value => name;

  static WorkActionType? parse(String? raw) {
    if (raw == null) return null;
    for (final value in WorkActionType.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

extension AgendaOperationalTargeting on AgendaEntry {
  WorkActionType? get workAction => WorkActionCodec.parse(actionKind);

  List<WorkTargetRef> get targetRefs => [
    ...animalIds.map(
      (id) => WorkTargetRef(type: WorkTargetType.animal, id: id),
    ),
    ...loteIds.map((id) => WorkTargetRef(type: WorkTargetType.lote, id: id)),
    if (locationUuid != null)
      WorkTargetRef(type: WorkTargetType.location, id: locationUuid!),
    if (cropUuid != null)
      WorkTargetRef(type: WorkTargetType.crop, id: cropUuid!),
  ];
}
