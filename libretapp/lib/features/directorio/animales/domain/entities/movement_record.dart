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
    super.id,
  });
  final String? fromLocation;
  final String toLocation;
  final MovementReason reason;
  final String? movedBy;

  MovementRecord copyWith({
    String? fromLocation,
    String? toLocation,
    DateTime? date,
    MovementReason? reason,
    String? notes,
    String? movedBy,
    String? id,
  }) {
    return MovementRecord(
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      movedBy: movedBy ?? this.movedBy,
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
  ];
}
