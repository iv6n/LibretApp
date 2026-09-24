/// Barrel — finanzas feature
///
/// Exports the BLoC layer, domain entities + repository contract,
/// infrastructure implementation, and the view page.
library;
export 'application/index.dart';
export 'domain/entities/animal_profitability.dart';
export 'domain/entities/financial_period_summary.dart';
export 'domain/entities/general_expense_record.dart';
export 'domain/entities/income_record.dart';
export 'domain/finance_summary_service.dart';
export 'domain/repositories/finanzas_repository.dart';
export 'infrastructure/isar_finanzas_repository.dart'
    if (dart.library.html) 'web_finanzas_infrastructure_stub.dart';
export 'view/view.dart';
export 'contabilidad/contabilidad.dart';
export 'facturacion/facturacion.dart';
export 'maquila/maquila.dart';
