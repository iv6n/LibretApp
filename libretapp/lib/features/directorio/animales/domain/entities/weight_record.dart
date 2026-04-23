import 'package:libretapp/core/models/timestamped_record.dart';

/// Métodos de medición de peso.
enum WeightMethod { scale, estimated }

/// Registro de peso del animal.
class WeightRecord extends TimestampedRecord {
  const WeightRecord({
    required super.date,
    required this.weight,
    required this.method,
    this.measuredBy,
    super.notes,
    super.id,
  });
  final double weight;
  final WeightMethod method;
  final String? measuredBy;

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
  List<Object?> get props => [...super.props, weight, method, measuredBy];
}
