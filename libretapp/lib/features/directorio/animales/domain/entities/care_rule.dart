import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';

enum CareType {
  vaccination,
  deworming,
  tickBath,
  supplement,
  hoofCare,
  reproductionCheck,
  custom,
}

/// Regla de manejo o sanidad que define cada cuanto aplicar una tarea.
class CareRule extends Equatable {
  final String id;
  final String name;
  final CareType type;
  final int intervalDays;
  final int? minIntervalDays;
  final int? maxIntervalDays;
  final int? leadTimeDays;
  final Species? species;
  final Sex? sex;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final bool mandatory;

  const CareRule({
    required this.id,
    required this.name,
    required this.type,
    required this.intervalDays,
    this.minIntervalDays,
    this.maxIntervalDays,
    this.leadTimeDays,
    this.species,
    this.sex,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.mandatory = true,
  });

  CareRule copyWith({
    String? id,
    String? name,
    CareType? type,
    int? intervalDays,
    int? minIntervalDays,
    int? maxIntervalDays,
    int? leadTimeDays,
    Species? species,
    Sex? sex,
    int? minAgeMonths,
    int? maxAgeMonths,
    bool? mandatory,
  }) {
    return CareRule(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      intervalDays: intervalDays ?? this.intervalDays,
      minIntervalDays: minIntervalDays ?? this.minIntervalDays,
      maxIntervalDays: maxIntervalDays ?? this.maxIntervalDays,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      species: species ?? this.species,
      sex: sex ?? this.sex,
      minAgeMonths: minAgeMonths ?? this.minAgeMonths,
      maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
      mandatory: mandatory ?? this.mandatory,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    intervalDays,
    minIntervalDays,
    maxIntervalDays,
    leadTimeDays,
    species,
    sex,
    minAgeMonths,
    maxAgeMonths,
    mandatory,
  ];
}
