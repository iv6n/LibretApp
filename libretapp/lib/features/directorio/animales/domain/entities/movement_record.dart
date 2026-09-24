/// features \u203a directorio \u203a animales \u203a domain \u203a entities \u203a movement_record \u2014 entity for an animal movement record.
library;

import 'package:libretapp/core/models/timestamped_record.dart';

/// Motivos del movimiento del animal.
enum MovementReason {
  paddockRotation,
  feeding,
  quarantine,
  treatment,
  breeding,
  relocation,
  transport,
  other;

  String get displayName {
    switch (this) {
      case MovementReason.paddockRotation:
        return 'Rotación de Potrero';
      case MovementReason.feeding:
        return 'Alimentación';
      case MovementReason.quarantine:
        return 'Cuarentena';
      case MovementReason.treatment:
        return 'Tratamiento';
      case MovementReason.breeding:
        return 'Reproducción';
      case MovementReason.relocation:
        return 'Reubicación';
      case MovementReason.transport:
        return 'Transporte';
      case MovementReason.other:
        return 'Otro';
    }
  }
}

/// Registro de movimiento de ubicación del animal.
class MovementRecord extends TimestampedRecord {
  const MovementRecord({
    this.fromLocation,
    required this.toLocation,
    required super.date,
    required this.reason,
    super.notes,
    this.movedBy,
    this.recordUuid,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    super.id,
  });
  final String? fromLocation;
  final String toLocation;
  final MovementReason reason;
  final String? movedBy;
  final String? recordUuid;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  MovementRecord copyWith({
    String? fromLocation,
    String? toLocation,
    DateTime? date,
    MovementReason? reason,
    String? notes,
    String? movedBy,
    String? recordUuid,
    DateTime? updatedAt,
    String? id,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  }) {
    return MovementRecord(
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      movedBy: movedBy ?? this.movedBy,
      recordUuid: recordUuid ?? this.recordUuid,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    fromLocation,
    toLocation,
    reason,
    movedBy,
    recordUuid,
    updatedAt,
    latitude,
    longitude,
    accuracyMeters,
  ];
}
