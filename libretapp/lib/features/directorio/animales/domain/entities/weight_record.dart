/// features \u203a directorio \u203a animales \u203a domain \u203a entities \u203a weight_record \u2014 entity for a weight measurement record.
library;

import 'package:libretapp/core/models/timestamped_record.dart';

/// Métodos de medición de peso.
enum WeightMethod { scale, estimated }

/// Registro de peso del animal.
class WeightRecord extends TimestampedRecord {
  const WeightRecord({
    required super.date,
    required this.weight,
    required this.method,
    this.animalUuid,
    this.lotUuid,
    this.measuredBy,
    this.recordUuid,
    this.createdAt,
    this.updatedAt,
    super.notes,
    super.id,
  });

  /// The animal is normally supplied by the repository scope. It is hydrated
  /// on reads so bulk calculations can keep the complete record context.
  final String? animalUuid;

  /// Lot membership at the moment this weighing was made. Existing records
  /// may be null because older versions did not store it.
  final String? lotUuid;

  final double weight;
  final WeightMethod method;
  final String? measuredBy;
  final String? recordUuid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Compatibility name for the public model described by the weighing
  /// feature. The existing app uses [date] everywhere.
  DateTime get measuredAt => date;

  /// Compatibility name for consumers that use the explicit kg suffix.
  double get weightKg => weight;

  WeightRecord copyWith({
    DateTime? date,
    double? weight,
    WeightMethod? method,
    Object? animalUuid = _unset,
    Object? lotUuid = _unset,
    String? measuredBy,
    String? recordUuid,
    Object? createdAt = _unset,
    DateTime? updatedAt,
    String? notes,
    String? id,
  }) {
    return WeightRecord(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      method: method ?? this.method,
      animalUuid: animalUuid == _unset
          ? this.animalUuid
          : animalUuid as String?,
      lotUuid: lotUuid == _unset ? this.lotUuid : lotUuid as String?,
      measuredBy: measuredBy ?? this.measuredBy,
      recordUuid: recordUuid ?? this.recordUuid,
      createdAt: createdAt == _unset ? this.createdAt : createdAt as DateTime?,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    animalUuid,
    lotUuid,
    weight,
    method,
    measuredBy,
    recordUuid,
    createdAt,
    updatedAt,
  ];
}

const Object _unset = Object();
