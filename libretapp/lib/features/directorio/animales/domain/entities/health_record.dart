import 'package:libretapp/core/models/timestamped_record.dart';

/// Tipos de registro de salud del animal.
enum HealthRecordType {
  vaccine,
  deworming,
  tickBath,
  vitamins,
  treatment,
  disease,
  death,
  checkup,
  other,
}

/// Registro de evento de salud del animal.
class HealthRecord extends TimestampedRecord {
  const HealthRecord({
    required super.date,
    required this.type,
    required this.product,
    this.dose,
    this.appliedBy,
    super.notes,
    this.nextDueDate,
    this.cause,
    super.id,
  });
  final HealthRecordType type;
  final String product;
  final String? dose;
  final String? appliedBy;
  final DateTime? nextDueDate;
  final String? cause;

  HealthRecord copyWith({
    DateTime? date,
    HealthRecordType? type,
    String? product,
    String? dose,
    String? appliedBy,
    String? notes,
    DateTime? nextDueDate,
    String? cause,
    String? id,
  }) {
    return HealthRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      product: product ?? this.product,
      dose: dose ?? this.dose,
      appliedBy: appliedBy ?? this.appliedBy,
      notes: notes ?? this.notes,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      cause: cause ?? this.cause,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    type,
    product,
    dose,
    appliedBy,
    nextDueDate,
    cause,
  ];
}
