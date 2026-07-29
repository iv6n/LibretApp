library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';

part 'isar_milking_session.g.dart';

@collection
class IsarMilkingSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late DateTime occurredAt;

  late String shift;

  @Index()
  late String status;

  @Index()
  String? sourceLoteUuid;

  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  late bool synced = false;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;
}

extension IsarMilkingSessionMapper on IsarMilkingSession {
  MilkingSession toEntity() => MilkingSession(
    uuid: uuid,
    occurredAt: occurredAt,
    shift: MilkingShift.values.byName(shift),
    status: MilkingStatus.values.byName(status),
    sourceLoteUuid: sourceLoteUuid,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension MilkingSessionToIsar on MilkingSession {
  IsarMilkingSession toIsar() => IsarMilkingSession()
    ..uuid = uuid
    ..occurredAt = occurredAt
    ..shift = shift.name
    ..status = status.name
    ..sourceLoteUuid = sourceLoteUuid
    ..notes = notes
    ..createdAt = createdAt
    ..updatedAt = updatedAt;
}
