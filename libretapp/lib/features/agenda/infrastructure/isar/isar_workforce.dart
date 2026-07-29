/// Isar schemas for local workers and work teams.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';

part 'isar_workforce.g.dart';

@collection
class IsarWorkerProfile {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(caseSensitive: false)
  late String name;

  late String role;
  String? phone;

  @Index()
  late bool active;

  late DateTime createdAt;
  late DateTime updatedAt;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  late bool synced = false;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;
}

@collection
class IsarWorkTeam {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(caseSensitive: false)
  late String name;

  late List<String> memberIds;

  @Index()
  late bool active;

  late DateTime createdAt;
  late DateTime updatedAt;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  late bool synced = false;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;
}

extension IsarWorkerProfileMapper on IsarWorkerProfile {
  WorkerProfile toEntity() => WorkerProfile(
    id: uuid,
    name: name,
    role: role,
    phone: phone,
    active: active,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension WorkerProfileToIsar on WorkerProfile {
  IsarWorkerProfile toIsar() => IsarWorkerProfile()
    ..uuid = id
    ..name = name
    ..role = role
    ..phone = phone
    ..active = active
    ..createdAt = createdAt
    ..updatedAt = updatedAt;
}

extension IsarWorkTeamMapper on IsarWorkTeam {
  WorkTeam toEntity() => WorkTeam(
    id: uuid,
    name: name,
    memberIds: List<String>.from(memberIds),
    active: active,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension WorkTeamToIsar on WorkTeam {
  IsarWorkTeam toIsar() => IsarWorkTeam()
    ..uuid = id
    ..name = name
    ..memberIds = List<String>.from(memberIds)
    ..active = active
    ..createdAt = createdAt
    ..updatedAt = updatedAt;
}
