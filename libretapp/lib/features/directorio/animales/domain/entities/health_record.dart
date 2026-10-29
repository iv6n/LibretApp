/// features \u203a directorio \u203a animales \u203a domain \u203a entities \u203a health_record \u2014 entity for a veterinary/health record.
library;

import 'package:libretapp/core/models/timestamped_record.dart';

const Object _unset = Object();

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
    this.recordUuid,
    this.updatedAt,
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

  /// Database-independent identifier used by Agenda and backup merges.
  final String? recordUuid;
  final DateTime? updatedAt;

  bool get isInWithdrawalPeriod =>
      withdrawalEndDate != null && withdrawalEndDate!.isAfter(DateTime.now());

  HealthRecord copyWith({
    DateTime? date,
    HealthRecordType? type,
    String? product,
    Object? dose = _unset,
    Object? appliedBy = _unset,
    Object? notes = _unset,
    Object? nextDueDate = _unset,
    Object? cause = _unset,
    Object? medicineBatch = _unset,
    Object? withdrawalDays = _unset,
    Object? withdrawalEndDate = _unset,
    String? recordUuid,
    DateTime? updatedAt,
    String? id,
  }) {
    return HealthRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      product: product ?? this.product,
      dose: dose == _unset ? this.dose : dose as String?,
      appliedBy: appliedBy == _unset ? this.appliedBy : appliedBy as String?,
      notes: notes == _unset ? this.notes : notes as String?,
      nextDueDate: nextDueDate == _unset
          ? this.nextDueDate
          : nextDueDate as DateTime?,
      cause: cause == _unset ? this.cause : cause as String?,
      medicineBatch: medicineBatch == _unset
          ? this.medicineBatch
          : medicineBatch as String?,
      withdrawalDays: withdrawalDays == _unset
          ? this.withdrawalDays
          : withdrawalDays as int?,
      withdrawalEndDate: withdrawalEndDate == _unset
          ? this.withdrawalEndDate
          : withdrawalEndDate as DateTime?,
      recordUuid: recordUuid ?? this.recordUuid,
      updatedAt: updatedAt ?? this.updatedAt,
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
    recordUuid,
    updatedAt,
  ];
}
