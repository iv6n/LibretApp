import 'package:libretapp/core/models/timestamped_record.dart';

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
class ProductionRecord extends TimestampedRecord {
  const ProductionRecord({
    required super.date,
    required this.type,
    this.value,
    this.unit,
    this.score,
    super.notes,
    super.id,
  });
  final ProductionRecordType type;
  final double? value;
  final String? unit;
  final int? score;

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
  List<Object?> get props => [...super.props, type, value, unit, score];
}
