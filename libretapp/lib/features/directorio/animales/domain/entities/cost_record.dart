import 'package:libretapp/core/models/timestamped_record.dart';

/// Tipos de costo por animal.
enum CostType { medication, feeding, labor, transport, investment }

/// Registro de costo asociado al animal.
class CostRecord extends TimestampedRecord {
  const CostRecord({
    required super.date,
    required this.type,
    required this.amount,
    this.currency,
    super.notes,
    super.id,
  });
  final CostType type;
  final double amount;
  final String? currency;

  CostRecord copyWith({
    DateTime? date,
    CostType? type,
    double? amount,
    String? currency,
    String? notes,
    String? id,
  }) {
    return CostRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [...super.props, type, amount, currency];
}
