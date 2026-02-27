import 'package:equatable/equatable.dart';

/// Tipos de costo por animal.
enum CostType { medication, feeding, labor, transport, investment }

/// Registro de costo asociado al animal.
class CostRecord extends Equatable {
  final DateTime date;
  final CostType type;
  final double amount;
  final String? currency;
  final String? notes;
  final String? id;

  const CostRecord({
    required this.date,
    required this.type,
    required this.amount,
    this.currency,
    this.notes,
    this.id,
  });

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
  List<Object?> get props => [date, type, amount, currency, notes, id];
}
