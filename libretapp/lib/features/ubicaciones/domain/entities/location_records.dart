import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';

typedef Money = double;

typedef Area = double;

class VisitRecord extends Equatable {
  final DateTime date;
  final int animals;
  final String? notes;
  final String? user;

  const VisitRecord({
    required this.date,
    required this.animals,
    this.notes,
    this.user,
  });

  @override
  List<Object?> get props => [date, animals, notes, user];
}

class WaterRecord extends Equatable {
  final DateTime date;
  final double level;
  final WaterType type;
  final String? notes;

  const WaterRecord({
    required this.date,
    required this.level,
    required this.type,
    this.notes,
  });

  @override
  List<Object?> get props => [date, level, type, notes];
}

class PastureRecord extends Equatable {
  final DateTime date;
  final String grassType;
  final String condition;
  final double carryingCapacity;

  const PastureRecord({
    required this.date,
    required this.grassType,
    required this.condition,
    required this.carryingCapacity,
  });

  @override
  List<Object?> get props => [date, grassType, condition, carryingCapacity];
}

class SeedingRecord extends Equatable {
  final DateTime date;
  final String crop;
  final Area surface;
  final Money cost;

  const SeedingRecord({
    required this.date,
    required this.crop,
    required this.surface,
    required this.cost,
  });

  @override
  List<Object?> get props => [date, crop, surface, cost];
}

class IrrigationRecord extends Equatable {
  final DateTime date;
  final String type;
  final Duration duration;
  final Money cost;

  const IrrigationRecord({
    required this.date,
    required this.type,
    required this.duration,
    required this.cost,
  });

  @override
  List<Object?> get props => [date, type, duration, cost];
}

class RainRecord extends Equatable {
  final DateTime date;
  final double millimeters;
  final String location;

  const RainRecord({
    required this.date,
    required this.millimeters,
    required this.location,
  });

  @override
  List<Object?> get props => [date, millimeters, location];
}

class CostRecord extends Equatable {
  final DateTime date;
  final Money maintenance;
  final Money fences;
  final Money repairs;
  final Money labor;
  final Money total;

  const CostRecord({
    required this.date,
    required this.maintenance,
    required this.fences,
    required this.repairs,
    required this.labor,
    required this.total,
  });

  CostRecord copyWith({
    DateTime? date,
    Money? maintenance,
    Money? fences,
    Money? repairs,
    Money? labor,
    Money? total,
  }) {
    return CostRecord(
      date: date ?? this.date,
      maintenance: maintenance ?? this.maintenance,
      fences: fences ?? this.fences,
      repairs: repairs ?? this.repairs,
      labor: labor ?? this.labor,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [date, maintenance, fences, repairs, labor, total];
}
