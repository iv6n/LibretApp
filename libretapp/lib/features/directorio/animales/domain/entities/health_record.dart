import 'package:equatable/equatable.dart';

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
class HealthRecord extends Equatable {
  const HealthRecord({
    required this.date,
    required this.type,
    required this.product,
    this.dose,
    this.appliedBy,
    this.notes,
    this.nextDueDate,
    this.cause,
    this.id,
  });
  final DateTime date;
  final HealthRecordType type;
  final String product;
  final String? dose;
  final String? appliedBy;
  final String? notes;
  final DateTime? nextDueDate;
  final String? cause;
  final String? id;

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
    date,
    type,
    product,
    dose,
    appliedBy,
    notes,
    nextDueDate,
    cause,
    id,
  ];
}
