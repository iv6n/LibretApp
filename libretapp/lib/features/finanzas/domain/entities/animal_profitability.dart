/// features \u203a finanzas \u203a domain \u203a entities \u203a animal_profitability \u2014 entity for per-animal profitability data.
library;

import 'package:equatable/equatable.dart';

/// Rentabilidad calculada para un animal individual.
/// Este modelo no se persiste — se calcula en tiempo de ejecución
/// usando los CostRecord y CommercialRecord del animal.
class AnimalProfitability extends Equatable {
  const AnimalProfitability({
    required this.animalUuid,
    required this.animalName,
    required this.purchaseCost,
    required this.totalCosts,
    required this.saleRevenue,
  });

  final String animalUuid;

  /// Nombre o identificador visible del animal.
  final String animalName;

  /// Precio de compra registrado en el animal (purchasePrice) o en su
  /// primer CommercialRecord de tipo purchase.
  final double purchaseCost;

  /// Suma acumulada de todos los CostRecord del animal.
  final double totalCosts;

  /// Suma acumulada de CommercialRecord de tipo sale.
  final double saleRevenue;

  /// Resultado neto = ingresos − costo de compra − costos operativos.
  double get netResult => saleRevenue - purchaseCost - totalCosts;

  /// Indica si el animal es rentable hasta el momento.
  bool get isProfitable => netResult >= 0;

  @override
  List<Object?> get props => [
    animalUuid,
    animalName,
    purchaseCost,
    totalCosts,
    saleRevenue,
  ];
}
