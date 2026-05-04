/// features \u203a directorio \u203a animales \u203a domain \u203a entities \u203a commercial_record \u2014 entity for a commercial transaction record.
library;

import 'package:libretapp/core/models/timestamped_record.dart';

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
class CommercialRecord extends TimestampedRecord {
  const CommercialRecord({
    required super.date,
    required this.type,
    this.amount,
    this.currency,
    this.counterparty,
    super.notes,
    super.id,
  });
  final CommercialRecordType type;
  final double? amount;
  final String? currency;
  final String? counterparty;

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
    ...super.props,
    type,
    amount,
    currency,
    counterparty,
  ];
}
