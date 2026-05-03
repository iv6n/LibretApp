import 'package:libretapp/core/models/timestamped_record.dart';

/// Categorías de gasto general de la finca (no asociado a un animal).
enum GeneralExpenseType {
  fuel,
  equipment,
  infrastructure,
  utilities,
  labor,
  taxes,
  other,
}

extension GeneralExpenseTypeLabel on GeneralExpenseType {
  String get label {
    switch (this) {
      case GeneralExpenseType.fuel:
        return 'Combustible';
      case GeneralExpenseType.equipment:
        return 'Equipos / Herramientas';
      case GeneralExpenseType.infrastructure:
        return 'Infraestructura';
      case GeneralExpenseType.utilities:
        return 'Servicios / Utilidades';
      case GeneralExpenseType.labor:
        return 'Mano de obra';
      case GeneralExpenseType.taxes:
        return 'Impuestos / Tasas';
      case GeneralExpenseType.other:
        return 'Otro';
    }
  }
}

/// Registro de gasto general de la finca.
/// No está asociado a un animal específico.
class GeneralExpenseRecord extends TimestampedRecord {
  const GeneralExpenseRecord({
    required super.date,
    required this.type,
    required this.amount,
    this.currency,
    super.notes,
    super.id,
  });

  final GeneralExpenseType type;
  final double amount;
  final String? currency;

  GeneralExpenseRecord copyWith({
    DateTime? date,
    GeneralExpenseType? type,
    double? amount,
    String? currency,
    String? notes,
    String? id,
  }) {
    return GeneralExpenseRecord(
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
