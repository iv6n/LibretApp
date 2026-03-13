import 'package:equatable/equatable.dart';

/// Métodos de medición de peso.
enum WeightMethod { scale, estimated }

/// Registro de peso del animal.
class WeightRecord extends Equatable {
  const WeightRecord({
    required this.date,
    required this.weight,
    required this.method,
    this.measuredBy,
    this.notes,
    this.id,
  });
  final DateTime date;
  final double weight;
  final WeightMethod method;
  final String? measuredBy;
  final String? notes;
  final String? id;

  WeightRecord copyWith({
    DateTime? date,
    double? weight,
    WeightMethod? method,
    String? measuredBy,
    String? notes,
    String? id,
  }) {
    return WeightRecord(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      method: method ?? this.method,
      measuredBy: measuredBy ?? this.measuredBy,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [date, weight, method, measuredBy, notes, id];
}
