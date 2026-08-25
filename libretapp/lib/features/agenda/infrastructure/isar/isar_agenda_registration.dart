library;

import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';

part 'isar_agenda_registration.g.dart';

@collection
class IsarAgendaRegistration {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String batchId;

  @Index()
  late String entryId;

  @Index()
  late String eventKey;

  @Index()
  String? animalId;

  late String kind;

  @Index()
  String? recordUuid;

  late DateTime performedAt;
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  String dataJson = '{}';
  List<String> evidencePaths = [];
}

extension IsarAgendaRegistrationMapper on IsarAgendaRegistration {
  AgendaRegistration toEntity() => AgendaRegistration(
    id: uuid,
    batchId: batchId,
    entryId: entryId,
    eventKey: eventKey,
    animalId: animalId,
    kind: AgendaRegistrationKind.values.firstWhere(
      (value) => value.name == kind,
      orElse: () => AgendaRegistrationKind.general,
    ),
    recordUuid: recordUuid,
    performedAt: performedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    data: _decodeData(dataJson),
    evidencePaths: List<String>.from(evidencePaths),
  );
}

extension AgendaRegistrationToIsar on AgendaRegistration {
  IsarAgendaRegistration toIsar() => IsarAgendaRegistration()
    ..uuid = id
    ..batchId = batchId
    ..entryId = entryId
    ..eventKey = eventKey
    ..animalId = animalId
    ..kind = kind.name
    ..recordUuid = recordUuid
    ..performedAt = performedAt
    ..createdAt = createdAt
    ..updatedAt = updatedAt
    ..dataJson = jsonEncode(data)
    ..evidencePaths = List<String>.from(evidencePaths);
}

Map<String, String> _decodeData(String raw) {
  try {
    final value = jsonDecode(raw);
    return value is Map ? Map<String, String>.from(value) : const {};
  } catch (_) {
    return const {};
  }
}
