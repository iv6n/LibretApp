/// core › demo › builders › demo_commercial_costs — commercial history and
/// per-animal costs for the demo herd.
///
/// `CommercialRecordRepository` flips `AnimalEntity.status` from a sale or
/// death record, so [aniVendidaSlug]/[aniMuertaSlug] are already authored
/// with the matching final `status` in `demo_animals.dart` — these records
/// are the transactional trail behind that status, not a contradicting one.
/// All amounts come from [DemoPriceBook] — nothing here is a magic number.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/builders/demo_price_book.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';

class DemoCommercialEntry {
  const DemoCommercialEntry({required this.animalSlug, required this.record});
  final String animalSlug;
  final CommercialRecord record;
}

class DemoCostEntry {
  const DemoCostEntry({required this.animalSlug, required this.record});
  final String animalSlug;
  final CostRecord record;
}

List<DemoCommercialEntry> buildDemoCommercialRecords({
  required DateTime reference,
}) {
  return [
    DemoCommercialEntry(
      animalSlug: aniVendidaSlug,
      record: CommercialRecord(
        date: daysBefore(reference, 90),
        type: CommercialRecordType.sale,
        amount: DemoPriceBook.historicalCalfSalePrice,
        currency: DemoPriceBook.currency,
        counterparty: 'Comprador DEMO',
        notes: 'Venta de becerro destetado. Registro de demostración.',
      ),
    ),
    DemoCommercialEntry(
      animalSlug: aniMuertaSlug,
      record: CommercialRecord(
        date: daysBefore(reference, 45),
        type: CommercialRecordType.writeOffDeath,
        counterparty: 'N/A',
        notes: 'Baja por muerte. Registro de demostración.',
      ),
    ),
    DemoCommercialEntry(
      animalSlug: aniPrietitaSlug,
      record: CommercialRecord(
        date: daysBefore(reference, 7),
        type: CommercialRecordType.purchase,
        amount: 9500,
        currency: DemoPriceBook.currency,
        counterparty: 'Vendedor DEMO',
        notes: 'Compra de vaquilla de reemplazo. Registro de demostración.',
      ),
    ),
  ];
}

List<DemoCostEntry> buildDemoCostRecords({required DateTime reference}) {
  return [
    DemoCostEntry(
      animalSlug: aniCuernitosSlug,
      record: CostRecord(
        date: daysBefore(reference, 4),
        type: CostType.medication,
        amount: DemoPriceBook.antibioticTreatmentCost,
        currency: DemoPriceBook.currency,
        notes: 'Tratamiento con antibiótico DEMO. Registro de demostración.',
      ),
    ),
    DemoCostEntry(
      animalSlug: aniNovillo1Slug,
      record: CostRecord(
        date: daysBefore(reference, 30),
        type: CostType.feeding,
        amount: DemoPriceBook.feedingCostPerAnimal,
        currency: DemoPriceBook.currency,
        notes: 'Alimentación en corral de engorda. Registro de demostración.',
      ),
    ),
    DemoCostEntry(
      animalSlug: aniVendidaSlug,
      record: CostRecord(
        date: daysBefore(reference, 90),
        type: CostType.transport,
        amount: DemoPriceBook.transportCostForSale,
        currency: DemoPriceBook.currency,
        notes: 'Flete para entrega al comprador. Registro de demostración.',
      ),
    ),
    DemoCostEntry(
      animalSlug: aniSasoSlug,
      record: CostRecord(
        date: daysBefore(reference, 20),
        type: CostType.labor,
        amount: DemoPriceBook.studLaborCost,
        currency: DemoPriceBook.currency,
        notes: 'Mano de obra de manejo reproductivo. Registro de demostración.',
      ),
    ),
    DemoCostEntry(
      animalSlug: aniPrietitaSlug,
      record: CostRecord(
        date: daysBefore(reference, 7),
        type: CostType.investment,
        amount: DemoPriceBook.breedingInvestmentCost,
        currency: DemoPriceBook.currency,
        notes: 'Inversión en vaquilla de reemplazo. Registro de demostración.',
      ),
    ),
  ];
}
