/// Shared GetIt registrations for the platform-neutral feature slices.
///
/// Native and web use different persistence and hardware implementations, but
/// these JSON repositories and their services have the same composition on
/// both platforms. Keeping the registrations here prevents the two roots from
/// drifting apart while each root retains its platform-specific services.
library;

import 'package:get_it/get_it.dart';
import 'package:libretapp/core/persistence/persistence.dart';
import 'package:libretapp/features/agenda/personal/personal.dart';
import 'package:libretapp/features/directorio/animales/reproduccion/reproduccion.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/alimentacion.dart';
import 'package:libretapp/features/directorio/lotes/engorda/engorda.dart';
import 'package:libretapp/features/finanzas/contabilidad/contabilidad.dart';
import 'package:libretapp/features/finanzas/maquila/maquila.dart';
import 'package:libretapp/features/registro/comercial/comercial.dart';
import 'package:libretapp/features/ubicaciones/almacen/almacen.dart';

/// Registers the feature-slice repositories and services shared by native and
/// web composition roots.
void registerPlanSlices(GetIt locator) {
  locator
    ..registerLazySingleton<JsonFeatureRepository<InventoryTransaction>>(
      () => JsonFeatureRepository<InventoryTransaction>(
        store: locator<FeatureRecordStore>(),
        kind: 'inventory.transaction',
        decode: InventoryTransaction.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<InventoryService>(
      () => InventoryService(
        locator<JsonFeatureRepository<InventoryTransaction>>(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<FeedPlan>>(
      () => JsonFeatureRepository<FeedPlan>(
        store: locator<FeatureRecordStore>(),
        kind: 'feed.plan',
        decode: FeedPlan.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<FeedExecution>>(
      () => JsonFeatureRepository<FeedExecution>(
        store: locator<FeatureRecordStore>(),
        kind: 'feed.execution',
        decode: FeedExecution.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<FeedService>(
      () => FeedService(
        plans: locator<JsonFeatureRepository<FeedPlan>>(),
        executions: locator<JsonFeatureRepository<FeedExecution>>(),
        inventory: locator<InventoryService>(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<FatteningCycle>>(
      () => JsonFeatureRepository<FatteningCycle>(
        store: locator<FeatureRecordStore>(),
        kind: 'fattening.cycle',
        decode: FatteningCycle.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<FatteningCalculator>(FatteningCalculator.new)
    ..registerLazySingleton<JsonFeatureRepository<ReproductionProtocol>>(
      () => JsonFeatureRepository<ReproductionProtocol>(
        store: locator<FeatureRecordStore>(),
        kind: 'reproduction.protocol',
        decode: ReproductionProtocol.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<ProtocolAssignment>>(
      () => JsonFeatureRepository<ProtocolAssignment>(
        store: locator<FeatureRecordStore>(),
        kind: 'reproduction.assignment',
        decode: ProtocolAssignment.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<ProtocolExecution>>(
      () => JsonFeatureRepository<ProtocolExecution>(
        store: locator<FeatureRecordStore>(),
        kind: 'reproduction.execution',
        decode: ProtocolExecution.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<ReproductionProtocolService>(
      () => ReproductionProtocolService(
        protocols: locator<JsonFeatureRepository<ReproductionProtocol>>(),
        assignments: locator<JsonFeatureRepository<ProtocolAssignment>>(),
        executions: locator<JsonFeatureRepository<ProtocolExecution>>(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<LedgerAccount>>(
      () => JsonFeatureRepository<LedgerAccount>(
        store: locator<FeatureRecordStore>(),
        kind: 'ledger.account',
        decode: LedgerAccount.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<JournalEntry>>(
      () => JsonFeatureRepository<JournalEntry>(
        store: locator<FeatureRecordStore>(),
        kind: 'ledger.entry',
        decode: JournalEntry.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<LedgerService>(
      () => LedgerService(
        accounts: locator<JsonFeatureRepository<LedgerAccount>>(),
        entries: locator<JsonFeatureRepository<JournalEntry>>(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<AttendanceRecord>>(
      () => JsonFeatureRepository<AttendanceRecord>(
        store: locator<FeatureRecordStore>(),
        kind: 'payroll.attendance',
        decode: AttendanceRecord.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<PayrollIncident>>(
      () => JsonFeatureRepository<PayrollIncident>(
        store: locator<FeatureRecordStore>(),
        kind: 'payroll.incident',
        decode: PayrollIncident.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<PayrollReceipt>>(
      () => JsonFeatureRepository<PayrollReceipt>(
        store: locator<FeatureRecordStore>(),
        kind: 'payroll.receipt',
        decode: PayrollReceipt.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<PayrollService>(
      () => PayrollService(
        attendance: locator<JsonFeatureRepository<AttendanceRecord>>(),
        incidents: locator<JsonFeatureRepository<PayrollIncident>>(),
        receipts: locator<JsonFeatureRepository<PayrollReceipt>>(),
      ),
    )
    ..registerLazySingleton<JsonFeatureRepository<CarcassRecord>>(
      () => JsonFeatureRepository<CarcassRecord>(
        store: locator<FeatureRecordStore>(),
        kind: 'commercial.carcass',
        decode: CarcassRecord.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<CanalService>(
      () => CanalService(locator<JsonFeatureRepository<CarcassRecord>>()),
    )
    ..registerLazySingleton<JsonFeatureRepository<MaquilaContract>>(
      () => JsonFeatureRepository<MaquilaContract>(
        store: locator<FeatureRecordStore>(),
        kind: 'maquila.contract',
        decode: MaquilaContract.fromJson,
        encode: (value) => value.toJson(),
      ),
    )
    ..registerLazySingleton<MaquilaService>(
      () => MaquilaService(locator<JsonFeatureRepository<MaquilaContract>>()),
    );
}
