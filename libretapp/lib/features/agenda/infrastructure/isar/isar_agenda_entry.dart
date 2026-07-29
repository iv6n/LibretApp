/// Isar persistence model for agenda tasks and their operational history.
library;

import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

part 'isar_agenda_entry.g.dart';

@collection
class IsarAgendaEntry {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String titulo;
  late String descripcion;

  @Index()
  late DateTime fecha;

  @Index()
  late String tipo;

  late List<String> animalIds;
  late List<String> loteIds;
  late String ubicacion;
  String? locationUuid;

  @Index()
  late String estado;

  @Index()
  late String prioridad;

  late List<String> completedAnimalIds;
  late String notas;
  DateTime? fechaCompletado;

  String? assigneeId;
  late List<String> collaboratorIds;
  String? workTeamId;
  String? createdById;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? recurrenceRule;
  String? blockedReason;

  late List<String> checklistJson;
  late List<String> activitiesJson;
  late List<String> evidenceJson;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  late bool synced = false;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;
}

extension IsarAgendaEntryMapper on IsarAgendaEntry {
  AgendaEntry toEntity() => AgendaEntry(
    id: uuid,
    titulo: titulo,
    descripcion: descripcion,
    fecha: fecha,
    tipo: tipo,
    animalIds: List<String>.from(animalIds),
    loteIds: List<String>.from(loteIds),
    ubicacion: ubicacion,
    locationUuid: locationUuid,
    estado: estado,
    prioridad: prioridad,
    completedAnimalIds: List<String>.from(completedAnimalIds),
    notas: notas,
    fechaCompletado: fechaCompletado,
    assigneeId: assigneeId,
    collaboratorIds: List<String>.from(collaboratorIds),
    workTeamId: workTeamId,
    createdById: createdById,
    createdAt: createdAt,
    updatedAt: updatedAt,
    recurrenceRule: recurrenceRule,
    blockedReason: blockedReason,
    checklist: checklistJson
        .map(
          (raw) => AgendaChecklistItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          ),
        )
        .toList(growable: false),
    activities: activitiesJson
        .map(
          (raw) => AgendaActivity.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          ),
        )
        .toList(growable: false),
    evidence: evidenceJson
        .map(
          (raw) => AgendaEvidence.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          ),
        )
        .toList(growable: false),
  );
}

extension AgendaEntryToIsar on AgendaEntry {
  IsarAgendaEntry toIsar() => IsarAgendaEntry()
    ..uuid = id
    ..titulo = titulo
    ..descripcion = descripcion
    ..fecha = fecha
    ..tipo = tipo
    ..animalIds = List<String>.from(animalIds)
    ..loteIds = List<String>.from(loteIds)
    ..ubicacion = ubicacion
    ..locationUuid = locationUuid
    ..estado = estado
    ..prioridad = prioridad
    ..completedAnimalIds = List<String>.from(completedAnimalIds)
    ..notas = notas
    ..fechaCompletado = fechaCompletado
    ..assigneeId = assigneeId
    ..collaboratorIds = List<String>.from(collaboratorIds)
    ..workTeamId = workTeamId
    ..createdById = createdById
    ..createdAt = createdAt
    ..updatedAt = updatedAt
    ..recurrenceRule = recurrenceRule
    ..blockedReason = blockedReason
    ..checklistJson = checklist.map((item) => jsonEncode(item.toJson())).toList()
    ..activitiesJson = activities
        .map((activity) => jsonEncode(activity.toJson()))
        .toList()
    ..evidenceJson = evidence.map((item) => jsonEncode(item.toJson())).toList();
}
