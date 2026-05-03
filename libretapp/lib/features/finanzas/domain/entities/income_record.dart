import 'package:libretapp/core/models/timestamped_record.dart';

/// Categorías de ingreso general de la finca.
enum IncomeType { milkSale, woolSale, service, subsidy, other }

extension IncomeTypeLabel on IncomeType {
  String get label {
    switch (this) {
      case IncomeType.milkSale:
        return 'Venta de leche';
      case IncomeType.woolSale:
        return 'Venta de lana';
      case IncomeType.service:
        return 'Servicio';
      case IncomeType.subsidy:
        return 'Subsidio / Ayuda';
      case IncomeType.other:
        return 'Otro';
    }
  }
}

/// Registro de ingreso general de la finca.
/// Puede vincularse opcionalmente a un animal mediante [animalUuid].
class IncomeRecord extends TimestampedRecord {
  const IncomeRecord({
    required super.date,
    required this.type,
    required this.amount,
    this.currency,
    this.animalUuid,
    super.notes,
    super.id,
  });

  final IncomeType type;
  final double amount;
  final String? currency;

  /// UUID del animal al que se asocia este ingreso (opcional).
  final String? animalUuid;

  IncomeRecord copyWith({
    DateTime? date,
    IncomeType? type,
    double? amount,
    String? currency,
    String? animalUuid,
    String? notes,
    String? id,
  }) {
    return IncomeRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      animalUuid: animalUuid ?? this.animalUuid,
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
    animalUuid,
  ];
}
