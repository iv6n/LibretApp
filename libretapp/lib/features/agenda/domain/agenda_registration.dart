/// Traceable execution records created from Agenda task cards.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

enum AgendaRegistrationKind { health, weight, movement, reproduction, general }

AgendaRegistrationKind registrationKindForEntry(AgendaEntry entry) {
  final action = entry.workAction;
  if (action != null) {
    return switch (action) {
      WorkActionType.recordHealth ||
      WorkActionType.recordCare => AgendaRegistrationKind.health,
      WorkActionType.weight => AgendaRegistrationKind.weight,
      WorkActionType.movement => AgendaRegistrationKind.movement,
      WorkActionType.reproductionCheck ||
      WorkActionType.calving => AgendaRegistrationKind.reproduction,
      _ => AgendaRegistrationKind.general,
    };
  }

  return switch (categoriaForTipo(entry.tipo)) {
    AgendaCategoria.sanidad => AgendaRegistrationKind.health,
    AgendaCategoria.produccion => AgendaRegistrationKind.weight,
    AgendaCategoria.movimientos => AgendaRegistrationKind.movement,
    AgendaCategoria.reproduccion => AgendaRegistrationKind.reproduction,
    AgendaCategoria.administracion ||
    AgendaCategoria.otros => AgendaRegistrationKind.general,
  };
}

String agendaRegistrationRowKey(String entryId, String? animalId) =>
    '$entryId::${animalId ?? 'general'}';

class AgendaRegistration extends Equatable {
  const AgendaRegistration({
    required this.id,
    required this.batchId,
    required this.entryId,
    required this.eventKey,
    required this.kind,
    required this.performedAt,
    required this.createdAt,
    required this.updatedAt,
    this.animalId,
    this.recordUuid,
    this.data = const {},
    this.evidencePaths = const [],
  });

  final String id;
  final String batchId;
  final String entryId;
  final String eventKey;
  final String? animalId;
  final AgendaRegistrationKind kind;
  final String? recordUuid;
  final DateTime performedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Canonical payload for tasks that do not have a specialized domain record.
  final Map<String, String> data;
  final List<String> evidencePaths;

  String get rowKey => agendaRegistrationRowKey(entryId, animalId);

  AgendaRegistration copyWith({
    String? id,
    String? batchId,
    String? entryId,
    String? eventKey,
    Object? animalId = _sentinel,
    AgendaRegistrationKind? kind,
    Object? recordUuid = _sentinel,
    DateTime? performedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? data,
    List<String>? evidencePaths,
  }) => AgendaRegistration(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    entryId: entryId ?? this.entryId,
    eventKey: eventKey ?? this.eventKey,
    animalId: animalId == _sentinel ? this.animalId : animalId as String?,
    kind: kind ?? this.kind,
    recordUuid: recordUuid == _sentinel
        ? this.recordUuid
        : recordUuid as String?,
    performedAt: performedAt ?? this.performedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    data: data ?? this.data,
    evidencePaths: evidencePaths ?? this.evidencePaths,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'batchId': batchId,
    'entryId': entryId,
    'eventKey': eventKey,
    if (animalId != null) 'animalId': animalId,
    'kind': kind.name,
    if (recordUuid != null) 'recordUuid': recordUuid,
    'performedAt': performedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'data': data,
    'evidencePaths': evidencePaths,
  };

  factory AgendaRegistration.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return AgendaRegistration(
      id: json['id'] as String,
      batchId: json['batchId'] as String? ?? '',
      entryId: json['entryId'] as String,
      eventKey: json['eventKey'] as String? ?? '',
      animalId: json['animalId'] as String?,
      kind: AgendaRegistrationKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => AgendaRegistrationKind.general,
      ),
      recordUuid: json['recordUuid'] as String?,
      performedAt:
          DateTime.tryParse(json['performedAt'] as String? ?? '') ?? now,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
      data: json['data'] is Map
          ? Map<String, String>.from(json['data'] as Map)
          : const {},
      evidencePaths:
          (json['evidencePaths'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    batchId,
    entryId,
    eventKey,
    animalId,
    kind,
    recordUuid,
    performedAt,
    createdAt,
    updatedAt,
    data,
    evidencePaths,
  ];
}

const Object _sentinel = Object();

class AgendaRegistrationDetail extends Equatable {
  const AgendaRegistrationDetail({
    required this.registration,
    required this.summary,
    required this.fields,
    this.recordMissing = false,
  });

  final AgendaRegistration registration;
  final String summary;
  final Map<String, String> fields;
  final bool recordMissing;

  String get rowKey => registration.rowKey;

  @override
  List<Object?> get props => [registration, summary, fields, recordMissing];
}

class AgendaRegistrationRowDraft extends Equatable {
  const AgendaRegistrationRowDraft({
    required this.row,
    required this.kind,
    required this.performedAt,
    this.healthRecord,
    this.weightRecord,
    this.movementRecord,
    this.reproductionRecord,
    this.generalData = const {},
    this.evidencePaths = const [],
    this.existingRegistration,
  });

  final AgendaTaskRow row;
  final AgendaRegistrationKind kind;
  final DateTime performedAt;
  final HealthRecord? healthRecord;
  final WeightRecord? weightRecord;
  final MovementRecord? movementRecord;
  final ReproductionRecord? reproductionRecord;
  final Map<String, String> generalData;
  final List<String> evidencePaths;
  final AgendaRegistration? existingRegistration;

  @override
  List<Object?> get props => [
    row,
    kind,
    performedAt,
    healthRecord,
    weightRecord,
    movementRecord,
    reproductionRecord,
    generalData,
    evidencePaths,
    existingRegistration,
  ];
}

class AgendaRegistrationRequest extends Equatable {
  const AgendaRegistrationRequest({
    required this.eventKey,
    required this.rows,
    this.batchId,
  });

  final String eventKey;
  final List<AgendaRegistrationRowDraft> rows;
  final String? batchId;

  @override
  List<Object?> get props => [eventKey, rows, batchId];
}

class AgendaRegistrationRowResult extends Equatable {
  const AgendaRegistrationRowResult({
    required this.draft,
    this.registration,
    this.error,
  });

  final AgendaRegistrationRowDraft draft;
  final AgendaRegistration? registration;
  final String? error;

  bool get succeeded => registration != null && error == null;

  @override
  List<Object?> get props => [draft, registration, error];
}

class AgendaRegistrationBatchResult extends Equatable {
  const AgendaRegistrationBatchResult(this.results);

  final List<AgendaRegistrationRowResult> results;

  List<AgendaRegistrationRowResult> get successes =>
      results.where((result) => result.succeeded).toList(growable: false);

  List<AgendaRegistrationRowResult> get failures =>
      results.where((result) => !result.succeeded).toList(growable: false);

  bool get allSucceeded => failures.isEmpty;

  @override
  List<Object?> get props => [results];
}
