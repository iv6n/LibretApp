/// features › agenda › data › agenda_model — domain entity for an agenda entry (task/event).
library;

import 'package:equatable/equatable.dart';

/// Task/event status constants.
class AgendaEstado {
  static const borrador = 'borrador';
  static const pendiente = 'pendiente';
  static const enProgreso = 'en_progreso';
  static const bloqueado = 'bloqueado';
  static const completado = 'completado';
  static const verificado = 'verificado';
  static const reprogramada = 'reprogramada';
  static const cancelado = 'cancelado';
}

class AgendaPrioridad {
  static const baja = 'baja';
  static const normal = 'normal';
  static const alta = 'alta';
  static const urgente = 'urgente';
}

class AgendaChecklistItem extends Equatable {
  const AgendaChecklistItem({
    required this.id,
    required this.label,
    this.completed = false,
    this.completedById,
    this.completedAt,
  });

  final String id;
  final String label;
  final bool completed;
  final String? completedById;
  final DateTime? completedAt;

  AgendaChecklistItem copyWith({
    bool? completed,
    Object? completedById = _agendaSentinel,
    Object? completedAt = _agendaSentinel,
  }) => AgendaChecklistItem(
    id: id,
    label: label,
    completed: completed ?? this.completed,
    completedById: completedById == _agendaSentinel
        ? this.completedById
        : completedById as String?,
    completedAt: completedAt == _agendaSentinel
        ? this.completedAt
        : completedAt as DateTime?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'completed': completed,
    if (completedById != null) 'completedById': completedById,
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
  };

  factory AgendaChecklistItem.fromJson(Map<String, dynamic> json) =>
      AgendaChecklistItem(
        id: json['id'] as String,
        label: json['label'] as String,
        completed: json['completed'] as bool? ?? false,
        completedById: json['completedById'] as String?,
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
      );

  @override
  List<Object?> get props => [id, label, completed, completedById, completedAt];
}

const Object _agendaSentinel = Object();

class AgendaActivity extends Equatable {
  const AgendaActivity({
    required this.id,
    required this.type,
    required this.timestamp,
    this.actorId,
    this.note,
  });

  final String id;
  final String type;
  final DateTime timestamp;
  final String? actorId;
  final String? note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    if (actorId != null) 'actorId': actorId,
    if (note != null) 'note': note,
  };

  factory AgendaActivity.fromJson(Map<String, dynamic> json) => AgendaActivity(
    id: json['id'] as String,
    type: json['type'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    actorId: json['actorId'] as String?,
    note: json['note'] as String?,
  );

  @override
  List<Object?> get props => [id, type, timestamp, actorId, note];
}

class AgendaEvidence extends Equatable {
  const AgendaEvidence({
    required this.id,
    required this.path,
    required this.createdAt,
    this.createdById,
    this.caption,
  });

  final String id;
  final String path;
  final DateTime createdAt;
  final String? createdById;
  final String? caption;

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
    if (createdById != null) 'createdById': createdById,
    if (caption != null) 'caption': caption,
  };

  factory AgendaEvidence.fromJson(Map<String, dynamic> json) => AgendaEvidence(
    id: json['id'] as String,
    path: json['path'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    createdById: json['createdById'] as String?,
    caption: json['caption'] as String?,
  );

  @override
  List<Object?> get props => [id, path, createdAt, createdById, caption];
}

class AgendaEntry extends Equatable {
  const AgendaEntry({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.hasExplicitTime = true,
    required this.tipo,
    required this.animalIds,
    required this.loteIds,
    required this.ubicacion,
    required this.estado,
    required this.completedAnimalIds,
    required this.notas,
    this.fechaCompletado,
    this.locationUuid,
    this.prioridad = AgendaPrioridad.normal,
    this.assigneeId,
    this.collaboratorIds = const [],
    this.workTeamId,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.recurrenceRule,
    this.blockedReason,
    this.remindAt,
    this.actionKind,
    this.sourceType,
    this.sourceId,
    this.planId,
    this.originalFecha,
    this.supersedesId,
    this.rescheduleReason,
    this.cropUuid,
    this.checklist = const [],
    this.activities = const [],
    this.evidence = const [],
  });

  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;

  /// False for a date-only task. Legacy records retain their stored time.
  final bool hasExplicitTime;
  final String tipo;

  /// IDs of animals assigned to this task. May be empty for general tasks.
  final List<String> animalIds;

  /// Lote names assigned to this task. Expanded to individual animals on execution.
  final List<String> loteIds;

  final String ubicacion;

  /// One of [AgendaEstado.pendiente], [AgendaEstado.enProgreso], [AgendaEstado.completado].
  final String estado;

  /// Subset of [animalIds] that have been individually completed.
  final List<String> completedAnimalIds;

  final String notas;
  final DateTime? fechaCompletado;

  /// UUID of the [LocationEntity] this entry is linked to. May be null for
  /// entries that predate location linking or have a free-text [ubicacion].
  final String? locationUuid;

  final String prioridad;
  final String? assigneeId;
  final List<String> collaboratorIds;
  final String? workTeamId;
  final String? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? recurrenceRule;
  final String? blockedReason;

  /// Date on which the reminder should become visible. The occurrence itself
  /// remains anchored to [fecha], so overdue work never loses its original
  /// scheduled date.
  final DateTime? remindAt;

  /// Stable operation identifier used by the domain form that opens when the
  /// user chooses "Registrar" (for example: recordHealth or cropWater).
  final String? actionKind;

  /// Source that generated this occurrence. Automatic entries use this pair
  /// as their reconciliation key; manual work may leave it null.
  final String? sourceType;
  final String? sourceId;

  /// Optional recurring work-plan identifier.
  final String? planId;

  /// Original date before a reprogramming chain began.
  final DateTime? originalFecha;

  /// Previous occurrence in a reprogramming chain.
  final String? supersedesId;

  /// Human-readable reason for a reprogramming decision.
  final String? rescheduleReason;

  /// Crop target. Location remains the physical work site.
  final String? cropUuid;

  final List<AgendaChecklistItem> checklist;
  final List<AgendaActivity> activities;
  final List<AgendaEvidence> evidence;

  static const _sentinel = Object();

  AgendaEntry copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    bool? hasExplicitTime,
    String? tipo,
    List<String>? animalIds,
    List<String>? loteIds,
    String? ubicacion,
    String? estado,
    List<String>? completedAnimalIds,
    String? notas,
    Object? fechaCompletado = _sentinel,
    Object? locationUuid = _sentinel,
    String? prioridad,
    Object? assigneeId = _sentinel,
    List<String>? collaboratorIds,
    Object? workTeamId = _sentinel,
    Object? createdById = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
    Object? recurrenceRule = _sentinel,
    Object? blockedReason = _sentinel,
    Object? remindAt = _sentinel,
    Object? actionKind = _sentinel,
    Object? sourceType = _sentinel,
    Object? sourceId = _sentinel,
    Object? planId = _sentinel,
    Object? originalFecha = _sentinel,
    Object? supersedesId = _sentinel,
    Object? rescheduleReason = _sentinel,
    Object? cropUuid = _sentinel,
    List<AgendaChecklistItem>? checklist,
    List<AgendaActivity>? activities,
    List<AgendaEvidence>? evidence,
  }) {
    return AgendaEntry(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      hasExplicitTime: hasExplicitTime ?? this.hasExplicitTime,
      tipo: tipo ?? this.tipo,
      animalIds: animalIds ?? this.animalIds,
      loteIds: loteIds ?? this.loteIds,
      ubicacion: ubicacion ?? this.ubicacion,
      estado: estado ?? this.estado,
      completedAnimalIds: completedAnimalIds ?? this.completedAnimalIds,
      notas: notas ?? this.notas,
      fechaCompletado: fechaCompletado == _sentinel
          ? this.fechaCompletado
          : fechaCompletado as DateTime?,
      locationUuid: locationUuid == _sentinel
          ? this.locationUuid
          : locationUuid as String?,
      prioridad: prioridad ?? this.prioridad,
      assigneeId: assigneeId == _sentinel
          ? this.assigneeId
          : assigneeId as String?,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      workTeamId: workTeamId == _sentinel
          ? this.workTeamId
          : workTeamId as String?,
      createdById: createdById == _sentinel
          ? this.createdById
          : createdById as String?,
      createdAt: createdAt == _sentinel
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt == _sentinel
          ? this.updatedAt
          : updatedAt as DateTime?,
      recurrenceRule: recurrenceRule == _sentinel
          ? this.recurrenceRule
          : recurrenceRule as String?,
      blockedReason: blockedReason == _sentinel
          ? this.blockedReason
          : blockedReason as String?,
      remindAt: remindAt == _sentinel ? this.remindAt : remindAt as DateTime?,
      actionKind: actionKind == _sentinel
          ? this.actionKind
          : actionKind as String?,
      sourceType: sourceType == _sentinel
          ? this.sourceType
          : sourceType as String?,
      sourceId: sourceId == _sentinel ? this.sourceId : sourceId as String?,
      planId: planId == _sentinel ? this.planId : planId as String?,
      originalFecha: originalFecha == _sentinel
          ? this.originalFecha
          : originalFecha as DateTime?,
      supersedesId: supersedesId == _sentinel
          ? this.supersedesId
          : supersedesId as String?,
      rescheduleReason: rescheduleReason == _sentinel
          ? this.rescheduleReason
          : rescheduleReason as String?,
      cropUuid: cropUuid == _sentinel ? this.cropUuid : cropUuid as String?,
      checklist: checklist ?? this.checklist,
      activities: activities ?? this.activities,
      evidence: evidence ?? this.evidence,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
    'hasExplicitTime': hasExplicitTime,
    'tipo': tipo,
    'animalIds': animalIds,
    'loteIds': loteIds,
    'ubicacion': ubicacion,
    'estado': estado,
    'completedAnimalIds': completedAnimalIds,
    'notas': notas,
    'fechaCompletado': fechaCompletado?.toIso8601String(),
    if (locationUuid != null) 'locationUuid': locationUuid,
    'prioridad': prioridad,
    if (assigneeId != null) 'assigneeId': assigneeId,
    'collaboratorIds': collaboratorIds,
    if (workTeamId != null) 'workTeamId': workTeamId,
    if (createdById != null) 'createdById': createdById,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (recurrenceRule != null) 'recurrenceRule': recurrenceRule,
    if (blockedReason != null) 'blockedReason': blockedReason,
    if (remindAt != null) 'remindAt': remindAt!.toIso8601String(),
    if (actionKind != null) 'actionKind': actionKind,
    if (sourceType != null) 'sourceType': sourceType,
    if (sourceId != null) 'sourceId': sourceId,
    if (planId != null) 'planId': planId,
    if (originalFecha != null)
      'originalFecha': originalFecha!.toIso8601String(),
    if (supersedesId != null) 'supersedesId': supersedesId,
    if (rescheduleReason != null) 'rescheduleReason': rescheduleReason,
    if (cropUuid != null) 'cropUuid': cropUuid,
    'checklist': checklist.map((item) => item.toJson()).toList(),
    'activities': activities.map((activity) => activity.toJson()).toList(),
    'evidence': evidence.map((item) => item.toJson()).toList(),
  };

  static AgendaEntry fromJson(Map<String, dynamic> json) {
    // Backward-compat: old records stored a single 'animalId' string.
    List<String> parseAnimalIds() {
      if (json.containsKey('animalIds')) {
        return (json['animalIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
      }
      final legacy = json['animalId'] as String? ?? '';
      return legacy.isNotEmpty && legacy != 'Sin asignar' ? [legacy] : [];
    }

    return AgendaEntry(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      fecha: DateTime.parse(json['fecha'] as String),
      hasExplicitTime: json['hasExplicitTime'] as bool? ?? true,
      tipo: json['tipo'] as String,
      animalIds: parseAnimalIds(),
      loteIds:
          (json['loteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ubicacion: json['ubicacion'] as String? ?? 'Sin ubicación',
      estado: json['estado'] as String? ?? AgendaEstado.pendiente,
      completedAnimalIds:
          (json['completedAnimalIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notas: json['notas'] as String? ?? '',
      fechaCompletado: json['fechaCompletado'] != null
          ? DateTime.parse(json['fechaCompletado'] as String)
          : null,
      locationUuid: json['locationUuid'] as String?,
      prioridad: json['prioridad'] as String? ?? AgendaPrioridad.normal,
      assigneeId: json['assigneeId'] as String?,
      collaboratorIds:
          (json['collaboratorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      workTeamId: json['workTeamId'] as String?,
      createdById: json['createdById'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      recurrenceRule: json['recurrenceRule'] as String?,
      blockedReason: json['blockedReason'] as String?,
      remindAt: json['remindAt'] == null
          ? null
          : DateTime.parse(json['remindAt'] as String),
      actionKind: json['actionKind'] as String?,
      sourceType: json['sourceType'] as String?,
      sourceId: json['sourceId'] as String?,
      planId: json['planId'] as String?,
      originalFecha: json['originalFecha'] == null
          ? null
          : DateTime.parse(json['originalFecha'] as String),
      supersedesId: json['supersedesId'] as String?,
      rescheduleReason: json['rescheduleReason'] as String?,
      cropUuid: json['cropUuid'] as String?,
      checklist:
          (json['checklist'] as List<dynamic>?)
              ?.map(
                (e) => AgendaChecklistItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map(
                (e) => AgendaActivity.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      evidence:
          (json['evidence'] as List<dynamic>?)
              ?.map(
                (e) => AgendaEvidence.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    fecha,
    hasExplicitTime,
    tipo,
    animalIds,
    loteIds,
    ubicacion,
    estado,
    completedAnimalIds,
    notas,
    fechaCompletado,
    locationUuid,
    prioridad,
    assigneeId,
    collaboratorIds,
    workTeamId,
    createdById,
    createdAt,
    updatedAt,
    recurrenceRule,
    blockedReason,
    remindAt,
    actionKind,
    sourceType,
    sourceId,
    planId,
    originalFecha,
    supersedesId,
    rescheduleReason,
    cropUuid,
    checklist,
    activities,
    evidence,
  ];
}
