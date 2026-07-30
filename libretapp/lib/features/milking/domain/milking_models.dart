library;

import 'package:equatable/equatable.dart';

enum MilkingShift {
  morning,
  afternoon,
  evening,
  other;

  String get label => switch (this) {
    MilkingShift.morning => 'Mañana',
    MilkingShift.afternoon => 'Tarde',
    MilkingShift.evening => 'Noche',
    MilkingShift.other => 'Otro',
  };

  static MilkingShift fromTime(DateTime value) {
    if (value.hour < 12) return MilkingShift.morning;
    if (value.hour < 18) return MilkingShift.afternoon;
    return MilkingShift.evening;
  }
}

enum MilkingStatus { draft, completed }

class MilkingSession extends Equatable {

  factory MilkingSession.fromJson(Map<String, dynamic> json) {
    return MilkingSession(
      uuid: json['uuid'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String).toLocal(),
      shift: MilkingShift.values.byName(json['shift'] as String),
      status: MilkingStatus.values.byName(json['status'] as String),
      sourceLoteUuid: json['sourceLoteUuid'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
  const MilkingSession({
    required this.uuid,
    required this.occurredAt,
    required this.shift,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sourceLoteUuid,
    this.notes,
  });

  final String uuid;
  final DateTime occurredAt;
  final MilkingShift shift;
  final MilkingStatus status;
  final String? sourceLoteUuid;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MilkingSession copyWith({
    DateTime? occurredAt,
    MilkingShift? shift,
    MilkingStatus? status,
    Object? sourceLoteUuid = _unset,
    Object? notes = _unset,
    DateTime? updatedAt,
  }) {
    return MilkingSession(
      uuid: uuid,
      occurredAt: occurredAt ?? this.occurredAt,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      sourceLoteUuid: sourceLoteUuid == _unset
          ? this.sourceLoteUuid
          : sourceLoteUuid as String?,
      notes: notes == _unset ? this.notes : notes as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'shift': shift.name,
    'status': status.name,
    'sourceLoteUuid': sourceLoteUuid,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [
    uuid,
    occurredAt,
    shift,
    status,
    sourceLoteUuid,
    notes,
    createdAt,
    updatedAt,
  ];
}

class MilkingEntry extends Equatable {

  factory MilkingEntry.fromJson(Map<String, dynamic> json) {
    return MilkingEntry(
      uuid: json['uuid'] as String,
      sessionUuid: json['sessionUuid'] as String,
      animalUuid: json['animalUuid'] as String,
      volumeMilliliters: json['volumeMilliliters'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
  const MilkingEntry({
    required this.uuid,
    required this.sessionUuid,
    required this.animalUuid,
    required this.volumeMilliliters,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String uuid;
  final String sessionUuid;
  final String animalUuid;
  final int volumeMilliliters;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get liters => volumeMilliliters / 1000;

  MilkingEntry copyWith({
    int? volumeMilliliters,
    Object? notes = _unset,
    DateTime? updatedAt,
  }) {
    return MilkingEntry(
      uuid: uuid,
      sessionUuid: sessionUuid,
      animalUuid: animalUuid,
      volumeMilliliters: volumeMilliliters ?? this.volumeMilliliters,
      notes: notes == _unset ? this.notes : notes as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'sessionUuid': sessionUuid,
    'animalUuid': animalUuid,
    'volumeMilliliters': volumeMilliliters,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [
    uuid,
    sessionUuid,
    animalUuid,
    volumeMilliliters,
    notes,
    createdAt,
    updatedAt,
  ];
}

class MilkingRecord extends Equatable {
  const MilkingRecord({required this.session, required this.entry});

  final MilkingSession session;
  final MilkingEntry entry;

  @override
  List<Object?> get props => [session, entry];
}

const Object _unset = Object();
