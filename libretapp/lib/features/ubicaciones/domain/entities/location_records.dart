import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';

typedef Money = double;

typedef Area = double;

class VisitRecord extends Equatable {
  const VisitRecord({
    required this.date,
    required this.animals,
    this.notes,
    this.user,
  });
  final DateTime date;
  final int animals;
  final String? notes;
  final String? user;

  @override
  List<Object?> get props => [date, animals, notes, user];
}

class WaterRecord extends Equatable {
  const WaterRecord({
    required this.date,
    required this.level,
    required this.type,
    this.notes,
  });
  final DateTime date;
  final double level;
  final WaterType type;
  final String? notes;

  @override
  List<Object?> get props => [date, level, type, notes];
}

class SaltRecord extends Equatable {
  const SaltRecord({required this.date, required this.quantityKg, this.notes});
  final DateTime date;
  final double quantityKg;
  final String? notes;

  @override
  List<Object?> get props => [date, quantityKg, notes];
}

class ShadeRecord extends Equatable {
  const ShadeRecord({
    required this.date,
    required this.shadePercent,
    required this.condition,
    this.notes,
  });
  final DateTime date;
  final double shadePercent;
  final String condition;
  final String? notes;

  @override
  List<Object?> get props => [date, shadePercent, condition, notes];
}

class PastureRecord extends Equatable {
  const PastureRecord({
    required this.date,
    required this.grassType,
    required this.condition,
    required this.carryingCapacity,
  });
  final DateTime date;
  final String grassType;
  final String condition;
  final double carryingCapacity;

  @override
  List<Object?> get props => [date, grassType, condition, carryingCapacity];
}

class SeedingRecord extends Equatable {
  const SeedingRecord({
    required this.date,
    required this.crop,
    required this.surface,
    required this.cost,
  });
  final DateTime date;
  final String crop;
  final Area surface;
  final Money cost;

  @override
  List<Object?> get props => [date, crop, surface, cost];
}

class IrrigationRecord extends Equatable {
  const IrrigationRecord({
    required this.date,
    required this.type,
    required this.duration,
    required this.cost,
  });
  final DateTime date;
  final String type;
  final Duration duration;
  final Money cost;

  @override
  List<Object?> get props => [date, type, duration, cost];
}

class RainRecord extends Equatable {
  const RainRecord({
    required this.date,
    required this.millimeters,
    required this.location,
  });
  final DateTime date;
  final double millimeters;
  final String location;

  @override
  List<Object?> get props => [date, millimeters, location];
}

// NOTE: This CostRecord shares its name with the animal CostRecord in
// features/directorio/animales/domain/entities/cost_record.dart.
// If both are needed in the same file, use a prefix import:
//   import '...' as location;
//   location.CostRecord(...)
class CostRecord extends Equatable {
  const CostRecord({
    required this.date,
    required this.maintenance,
    required this.fences,
    required this.repairs,
    required this.labor,
    required this.total,
  });
  final DateTime date;
  final Money maintenance;
  final Money fences;
  final Money repairs;
  final Money labor;
  final Money total;

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
