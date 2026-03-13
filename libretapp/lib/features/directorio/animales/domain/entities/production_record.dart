import 'package:equatable/equatable.dart';

/// Tipos de registro productivo.
enum ProductionRecordType {
  weighing,
  weightGain,
  production,
  bodyConditionScore,
  fatteningStart,
  fatteningEnd,
}

/// Registro productivo para un animal.
class ProductionRecord extends Equatable {
  const ProductionRecord({
    required this.date,
    required this.type,
    this.value,
    this.unit,
    this.score,
    this.notes,
    this.id,
  });
  final DateTime date;
  final ProductionRecordType type;
  final double? value;
  final String? unit;
  final int? score;
  final String? notes;
  final String? id;

  ProductionRecord copyWith({
    DateTime? date,
    ProductionRecordType? type,
    double? value,
    String? unit,
    int? score,
    String? notes,
    String? id,
  }) {
    return ProductionRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [date, type, value, unit, score, notes, id];
}
