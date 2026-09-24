/// Domain contracts for field hardware and RFID capture.
library;

import 'package:equatable/equatable.dart';

enum HardwareConnectionState {
  unavailable,
  discovering,
  connecting,
  connected,
  scanning,
  disconnected,
  error,
}

enum RfidBindingStatus { active, retired }

enum RfidBindingSource { manual, reader, import }

class RfidDeviceDescriptor extends Equatable {
  const RfidDeviceDescriptor({
    required this.id,
    required this.name,
    required this.transport,
    this.model,
  });

  final String id;
  final String name;
  final String transport;
  final String? model;

  @override
  List<Object?> get props => [id, name, transport, model];
}

class RfidTagRead extends Equatable {
  const RfidTagRead({
    required this.epc,
    required this.readAt,
    this.tid,
    this.rssi,
    this.deviceId,
  });

  final String epc;
  final String? tid;
  final int? rssi;
  final DateTime readAt;
  final String? deviceId;

  String get normalizedEpc => RfidTagNormalizer.normalize(epc);

  @override
  List<Object?> get props => [epc, tid, rssi, readAt, deviceId];
}

class RfidBindingRecord extends Equatable {
  const RfidBindingRecord({
    required this.uuid,
    required this.tagEpc,
    required this.animalUuid,
    required this.status,
    required this.source,
    required this.assignedAt,
    required this.updatedAt,
    this.tagTid,
    this.retiredAt,
  });

  final String uuid;
  final String tagEpc;
  final String? tagTid;
  final String animalUuid;
  final RfidBindingStatus status;
  final RfidBindingSource source;
  final DateTime assignedAt;
  final DateTime? retiredAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    uuid,
    tagEpc,
    tagTid,
    animalUuid,
    status,
    source,
    assignedAt,
    retiredAt,
    updatedAt,
  ];
}

class RfidScanSession extends Equatable {
  const RfidScanSession({
    required this.uuid,
    required this.startedAt,
    required this.deviceId,
    required this.source,
    required this.tagCount,
    required this.uniqueTagCount,
    this.endedAt,
    this.locationUuid,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final String uuid;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String deviceId;
  final RfidBindingSource source;
  final String? locationUuid;
  final int tagCount;
  final int uniqueTagCount;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  @override
  List<Object?> get props => [
    uuid,
    startedAt,
    endedAt,
    deviceId,
    source,
    locationUuid,
    tagCount,
    uniqueTagCount,
    latitude,
    longitude,
    accuracyMeters,
  ];
}

class ScaleReading extends Equatable {
  const ScaleReading({
    required this.valueKg,
    required this.capturedAt,
    required this.stable,
    this.deviceId,
  });

  final double valueKg;
  final DateTime capturedAt;
  final String? deviceId;
  final bool stable;

  @override
  List<Object?> get props => [valueKg, capturedAt, deviceId, stable];
}

abstract interface class RfidReaderAdapter {
  Stream<RfidTagRead> get reads;
  HardwareConnectionState get state;
  Future<List<RfidDeviceDescriptor>> discover();
  Future<void> connect(RfidDeviceDescriptor device);
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> disconnect();
}

abstract interface class ScaleAdapter {
  Stream<ScaleReading> get readings;
  Future<List<RfidDeviceDescriptor>> discover();
  Future<void> connect(RfidDeviceDescriptor device);
  Future<ScaleReading> readStable();
  Future<void> disconnect();
}

abstract interface class RfidRepository {
  Future<List<RfidBindingRecord>> listBindings({String? animalUuid});
  Future<RfidBindingRecord?> activeBindingForTag(String tagEpc);
  Future<RfidBindingRecord> assignTag({
    required String tagEpc,
    String? tagTid,
    required String animalUuid,
    RfidBindingSource source,
  });
  Future<void> retireBinding(String bindingUuid);
  Future<void> saveScanSession(RfidScanSession session);
  Future<List<RfidScanSession>> listScanSessions();
}

class RfidBindingConflict implements Exception {
  const RfidBindingConflict(this.message);

  final String message;

  @override
  String toString() => message;
}

class RfidTagNormalizer {
  const RfidTagNormalizer._();

  static String normalize(String raw) {
    return raw.trim().toUpperCase().replaceAll(RegExp(r'[:\-\s]'), '');
  }

  static bool isValid(String raw) => normalize(raw).isNotEmpty;
}
