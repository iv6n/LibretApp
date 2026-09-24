/// Isar persistence models for RFID associations and scan sessions.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/rfid/domain/rfid_models.dart';

part 'isar_rfid.g.dart';

@collection
class IsarRfidBinding {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String tagEpc;

  String? tagTid;

  @Index()
  late String animalUuid;

  late String status;
  late String source;
  late DateTime assignedAt;
  DateTime? retiredAt;
  late DateTime updatedAt;
}

@collection
class IsarRfidScanSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late DateTime startedAt;
  DateTime? endedAt;
  late String deviceId;
  late String source;
  String? locationUuid;
  late int tagCount;
  late int uniqueTagCount;
  double? latitude;
  double? longitude;
  double? accuracyMeters;
}

extension IsarRfidBindingMapper on IsarRfidBinding {
  RfidBindingRecord toEntity() => RfidBindingRecord(
    uuid: uuid,
    tagEpc: tagEpc,
    tagTid: tagTid,
    animalUuid: animalUuid,
    status: RfidBindingStatus.values.byName(status),
    source: RfidBindingSource.values.byName(source),
    assignedAt: assignedAt,
    retiredAt: retiredAt,
    updatedAt: updatedAt,
  );
}

extension IsarRfidScanSessionMapper on IsarRfidScanSession {
  RfidScanSession toEntity() => RfidScanSession(
    uuid: uuid,
    startedAt: startedAt,
    endedAt: endedAt,
    deviceId: deviceId,
    source: RfidBindingSource.values.byName(source),
    locationUuid: locationUuid,
    tagCount: tagCount,
    uniqueTagCount: uniqueTagCount,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
  );
}

extension RfidBindingToIsar on RfidBindingRecord {
  IsarRfidBinding toIsar() => IsarRfidBinding()
    ..uuid = uuid
    ..tagEpc = tagEpc
    ..tagTid = tagTid
    ..animalUuid = animalUuid
    ..status = status.name
    ..source = source.name
    ..assignedAt = assignedAt
    ..retiredAt = retiredAt
    ..updatedAt = updatedAt;
}

extension RfidScanSessionToIsar on RfidScanSession {
  IsarRfidScanSession toIsar() => IsarRfidScanSession()
    ..uuid = uuid
    ..startedAt = startedAt
    ..endedAt = endedAt
    ..deviceId = deviceId
    ..source = source.name
    ..locationUuid = locationUuid
    ..tagCount = tagCount
    ..uniqueTagCount = uniqueTagCount
    ..latitude = latitude
    ..longitude = longitude
    ..accuracyMeters = accuracyMeters;
}
