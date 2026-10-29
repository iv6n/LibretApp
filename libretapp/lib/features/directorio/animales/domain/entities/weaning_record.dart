library;

import 'package:libretapp/core/models/timestamped_record.dart';
import 'weight_record.dart';

class WeaningRecord extends TimestampedRecord {
  const WeaningRecord({
    required this.animalUuid,
    required super.date,
    this.weightKg,
    this.weightMethod = WeightMethod.scale,
    this.weightRecordUuid,
    this.performedBy,
    this.recordUuid,
    this.updatedAt,
    super.notes,
    super.id,
  });

  final String animalUuid;
  final double? weightKg;
  final WeightMethod weightMethod;
  final String? weightRecordUuid;
  final String? performedBy;
  final String? recordUuid;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    ...super.props,
    animalUuid,
    weightKg,
    weightMethod,
    weightRecordUuid,
    performedBy,
    recordUuid,
    updatedAt,
  ];
}
