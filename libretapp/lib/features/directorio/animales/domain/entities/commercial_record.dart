import 'package:equatable/equatable.dart';

/// Tipos de evento comercial.
enum CommercialRecordType {
  purchase,
  sale,
  ownershipChange,
  priceUpdate,
  writeOffSale,
  writeOffDeath,
}

/// Registro comercial del animal.
class CommercialRecord extends Equatable {
  const CommercialRecord({
    required this.date,
    required this.type,
    this.amount,
    this.currency,
    this.counterparty,
    this.notes,
    this.id,
  });
  final DateTime date;
  final CommercialRecordType type;
  final double? amount;
  final String? currency;
  final String? counterparty;
  final String? notes;
  final String? id;

  CommercialRecord copyWith({
    DateTime? date,
    CommercialRecordType? type,
    double? amount,
    String? currency,
    String? counterparty,
    String? notes,
    String? id,
  }) {
    return CommercialRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      counterparty: counterparty ?? this.counterparty,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    date,
    type,
    amount,
    currency,
    counterparty,
    notes,
    id,
  ];
}
