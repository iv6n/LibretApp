/// features \u203a directorio \u203a animales \u203a domain \u203a entities \u203a health_record \u2014 entity for a veterinary/health record.
library;

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
  other;

  String get displayName {
    switch (this) {
      case HealthRecordType.vaccine:
        return 'Vacuna';
      case HealthRecordType.deworming:
        return 'Desparasitación';
      case HealthRecordType.tickBath:
        return 'Baño garrapaticida';
      case HealthRecordType.vitamins:
        return 'Vitaminas';
      case HealthRecordType.treatment:
        return 'Tratamiento';
      case HealthRecordType.disease:
        return 'Enfermedad';
      case HealthRecordType.death:
        return 'Muerte';
      case HealthRecordType.checkup:
        return 'Chequeo';
      case HealthRecordType.other:
        return 'Otro';
    }
  }
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
    this.medicineBatch,
    this.withdrawalDays,
    this.withdrawalEndDate,
    super.id,
  });
  final HealthRecordType type;
  final String product;
  final String? dose;
  final String? appliedBy;
  final DateTime? nextDueDate;
  final String? cause;
  final String? medicineBatch;
  final int? withdrawalDays;
  final DateTime? withdrawalEndDate;

  bool get isInWithdrawalPeriod =>
      withdrawalEndDate != null && withdrawalEndDate!.isAfter(DateTime.now());

  HealthRecord copyWith({
    DateTime? date,
    HealthRecordType? type,
    String? product,
    String? dose,
    String? appliedBy,
    String? notes,
    DateTime? nextDueDate,
    String? cause,
    String? medicineBatch,
    int? withdrawalDays,
    DateTime? withdrawalEndDate,
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
      medicineBatch: medicineBatch ?? this.medicineBatch,
      withdrawalDays: withdrawalDays ?? this.withdrawalDays,
      withdrawalEndDate: withdrawalEndDate ?? this.withdrawalEndDate,
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
    medicineBatch,
    withdrawalDays,
    withdrawalEndDate,
  ];
}
