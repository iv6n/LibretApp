/// Browser composition root.
library;

import 'package:get_it/get_it.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/onboarding/profile_onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/backup/backup.dart';
import 'package:libretapp/core/di/injection_web_repositories.dart';
import 'package:libretapp/core/di/web/farm_record_access.dart';
import 'package:libretapp/core/media/media_store.dart';
import 'package:libretapp/core/persistence/persistence.dart';
import 'package:libretapp/core/security/security.dart';
import 'package:libretapp/core/services/animal_excel_import_service.dart';
import 'package:libretapp/core/services/herd_import_service.dart';
import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/database/feature_store_transaction_runner.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/theme_repository.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/core/sync/sync.dart';
import 'package:libretapp/features/agenda/data/agenda_registration_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_refresh_signal.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration_coordinator.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration_read_service.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_identification.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/engorda/engorda.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/alimentacion.dart';
import 'package:libretapp/features/directorio/animales/reproduccion/reproduccion.dart';
import 'package:libretapp/features/agenda/personal/personal.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/finanzas/facturacion/facturacion.dart';
import 'package:libretapp/features/finanzas/contabilidad/contabilidad.dart';
import 'package:libretapp/features/finanzas/maquila/maquila.dart';
import 'package:libretapp/features/registro/comercial/comercial.dart';
import 'package:libretapp/features/inicio/asistente/asistente.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/features/inicio/data/weather_preferences_service.dart';
import 'package:libretapp/features/inicio/data/weather_alerts_service.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_shared_prefs_repository.dart';
import 'package:libretapp/features/perfil/suscripcion/suscripcion.dart';
import 'package:libretapp/features/reportes/domain/report_summary_service.dart';
import 'package:libretapp/features/reportes/mexico/mexico.dart';
import 'package:libretapp/features/rfid/rfid.dart';
import 'package:libretapp/features/ubicaciones/almacen/almacen.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/core/connectivity/offline_status_service.dart';
import 'package:libretapp/core/location/gps_capture_service.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';

final locator = GetIt.instance;

Future<void> disposeLocator() async {
  ReleaseFeatures.demoMode = false;
  final store = locator.isRegistered<FeatureRecordStore>()
      ? locator<FeatureRecordStore>()
      : null;
  await locator.reset();
  if (store is DriftFeatureRecordStore) await store.close();
}

Future<bool> workspaceHasUserData() async {
  if (locator<SharedPrefsService>().getString('perfil_v1') != null) return true;
  return (await locator<FeatureRecordStore>().listAll()).any(
    (row) => !const {
      'core.farm',
      'core.farm_membership',
      'core.farm_context',
      'core.migration',
    }.contains(row.kind),
  );
}

Future<void> setupLocator({
  LocalWorkspace workspace = const LocalWorkspace(
    id: 'legacy',
    kind: WorkspaceKind.guest,
    legacy: true,
  ),
}) async {
  ReleaseFeatures.demoMode = workspace.isDemo;
  final prefs = SharedPrefsService(
    await SharedPreferences.getInstance(),
    prefix: workspace.preferencePrefix,
  );
  final store = await DriftFeatureRecordStore.open(
    databaseName: workspace.legacy
        ? 'libretapp_features'
        : 'libretapp_${workspace.id}',
  );
  locator.registerSingleton<LocalWorkspace>(workspace);
  locator
    ..registerSingleton<SharedPrefsService>(prefs)
    ..registerSingleton<FeatureRecordStore>(store)
    ..registerLazySingleton<ThemeRepository>(() => ThemeRepository(prefs))
    ..registerLazySingleton<MediaStore>(MediaStore.new)
    ..registerLazySingleton<FarmContextRepository>(
      () => IsarFarmContextRepository(store),
    )
    ..registerLazySingleton<FarmMigrationService>(
      () => FarmMigrationService(locator<FarmContextRepository>(), store),
    )
    ..registerLazySingleton<SensitiveLoggerPort>(SecureLoggerService.new)
    ..registerLazySingleton<SecureStorePort>(
      () => PrefsKeyValueStoreService(prefs),
    )
    ..registerLazySingleton<KeyProviderPort>(DefaultKeyProviderService.new)
    ..registerLazySingleton<CryptoPort>(CryptoStubService.new)
    ..registerLazySingleton<TokenPort>(
      () => TokenStoreService(
        secureStore: locator<SecureStorePort>(),
        cryptoPort: locator<CryptoPort>(),
        keyProvider: locator<KeyProviderPort>(),
      ),
    )
    ..registerLazySingleton<AuthPort>(
      () => AuthService(
        tokenPort: locator<TokenPort>(),
        logger: locator<SensitiveLoggerPort>(),
      ),
    )
    ..registerLazySingleton<AnimalRepository>(
      () => WebAnimalRepository(store, locator<FarmContextRepository>()),
    )
    ..registerLazySingleton<FarmRecordAccess>(
      () => FarmRecordAccess(store, locator<FarmContextRepository>()),
    )
    ..registerLazySingleton<LotesRepository>(
      () => WebLotesRepository(
        locator<FarmRecordAccess>(),
        locator<AnimalRepository>(),
      ),
    )
    ..registerLazySingleton<LocationRepository>(
      () => WebLocationRepository(locator<FarmRecordAccess>()),
    )
    ..registerLazySingleton<CultivationRepository>(WebCultivationRepository.new)
    ..registerLazySingleton<AgendaRepository>(() => AgendaRepositoryImpl(prefs))
    ..registerLazySingleton<AgendaRegistrationRepository>(
      WebAgendaRegistrationRepository.new,
    )
    ..registerLazySingleton<WorkforceRepository>(WebWorkforceRepository.new)
    ..registerLazySingleton<WeightRecordRepository>(
      () => WebWeightRecordRepository(
        locator<FarmRecordAccess>(),
        locator<AnimalRepository>(),
      ),
    )
    ..registerLazySingleton<HealthRecordRepository>(
      () => WebHealthRecordRepository(
        locator<FarmRecordAccess>(),
        locator<AnimalRepository>(),
      ),
    )
    ..registerLazySingleton<ProductionRecordRepository>(
      WebProductionRecordRepository.new,
    )
    ..registerLazySingleton<ReproductionRecordRepository>(
      WebReproductionRecordRepository.new,
    )
    ..registerLazySingleton<CommercialRecordRepository>(
      WebCommercialRecordRepository.new,
    )
    ..registerLazySingleton<MovementRecordRepository>(
      () => WebMovementRecordRepository(
        locator<FarmRecordAccess>(),
        locator<AnimalRepository>(),
        locator<LocationRepository>(),
        locator<LotesRepository>(),
      ),
    )
    ..registerLazySingleton<CostRecordRepository>(WebCostRecordRepository.new)
    ..registerLazySingleton<CareRepository>(WebCareRepository.new)
    ..registerLazySingleton<MilkingRepository>(WebMilkingRepository.new)
    ..registerLazySingleton<FinanzasRepository>(WebFinanzasRepository.new)
    ..registerLazySingleton<PerfilRepository>(
      () => PerfilSharedPrefsRepository(prefs),
    )
    ..registerLazySingleton<ProfileOnboardingService>(
      () => ProfileOnboardingService(
        workspace: workspace,
        preferences: prefs,
        repository: locator<PerfilRepository>(),
      ),
    )
    ..registerLazySingleton<AnimalExcelImportService>(
      () => AnimalExcelImportService(
        animalRepository: locator<AnimalRepository>(),
      ),
    )
    ..registerLazySingleton<WriteTransactionRunner>(
      () => FeatureStoreTransactionRunner(store),
    )
    ..registerLazySingleton<BatchRecordService>(
      () => BatchRecordService(
        store: store,
        transactions: locator<WriteTransactionRunner>(),
        context: locator<FarmContextRepository>(),
        animals: locator<AnimalRepository>(),
        lots: locator<LotesRepository>(),
        health: locator<HealthRecordRepository>(),
        weights: locator<WeightRecordRepository>(),
        movements: locator<MovementRecordRepository>(),
        locations: locator<LocationRepository>(),
      ),
    )
    ..registerLazySingleton<HerdImportService>(
      () => HerdImportService(
        animals: locator<AnimalRepository>(),
        transactions: locator<WriteTransactionRunner>(),
        context: locator<FarmContextRepository>(),
      ),
    )
    ..registerLazySingleton<AgendaRefreshSignal>(AgendaRefreshSignal.new)
    ..registerLazySingleton<CareCalendarService>(
      () => CareCalendarService(locator<CareRepository>()),
    )
    ..registerLazySingleton<HealthCareCycleService>(
      () => HealthCareCycleService(locator<CareRepository>()),
    )
    ..registerLazySingleton<AgendaRegistrationReadService>(
      () => AgendaRegistrationReadService(
        healthRepository: locator<HealthRecordRepository>(),
        weightRepository: locator<WeightRecordRepository>(),
        movementRepository: locator<MovementRecordRepository>(),
        reproductionRepository: locator<ReproductionRecordRepository>(),
      ),
    )
    ..registerLazySingleton<AgendaReminderSyncService>(
      () => AgendaReminderSyncService(
        animalRepository: locator<AnimalRepository>(),
        agendaRepository: locator<AgendaRepository>(),
        healthRepo: locator<HealthRecordRepository>(),
        reproductionRepo: locator<ReproductionRecordRepository>(),
        careRepo: locator<CareRepository>(),
        careCalendarService: locator<CareCalendarService>(),
        locationRepository: locator<LocationRepository>(),
        cultivationRepository: locator<CultivationRepository>(),
        refreshSignal: locator<AgendaRefreshSignal>(),
      ),
    )
    ..registerLazySingleton<AgendaRegistrationCoordinator>(
      () => AgendaRegistrationCoordinator(
        agendaRepository: locator<AgendaRepository>(),
        registrationRepository: locator<AgendaRegistrationRepository>(),
        healthRepository: locator<HealthRecordRepository>(),
        weightRepository: locator<WeightRecordRepository>(),
        movementRepository: locator<MovementRecordRepository>(),
        reproductionRepository: locator<ReproductionRecordRepository>(),
        careRepository: locator<CareRepository>(),
        lotesRepository: locator<LotesRepository>(),
        reminderSyncService: locator<AgendaReminderSyncService>(),
        refreshSignal: locator<AgendaRefreshSignal>(),
      ),
    )
    ..registerLazySingleton<AnimalEditService>(
      () => AnimalEditService(
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
        movementRepository: locator<MovementRecordRepository>(),
        careRepository: locator<CareRepository>(),
        agendaReminderSyncService: locator<AgendaReminderSyncService>(),
        careCalendarService: locator<CareCalendarService>(),
      ),
    )
    ..registerLazySingleton<OfflineStatusService>(OfflineStatusService.new)
    ..registerLazySingleton<GpsCaptureService>(GpsCaptureService.new)
    ..registerLazySingleton<SimulatedRfidReaderAdapter>(
      SimulatedRfidReaderAdapter.new,
    )
    ..registerLazySingleton<SimulatedScaleAdapter>(SimulatedScaleAdapter.new)
    ..registerLazySingleton<RfidReaderAdapter>(
      () => locator<SimulatedRfidReaderAdapter>(),
    )
    ..registerLazySingleton<ScaleAdapter>(
      () => locator<SimulatedScaleAdapter>(),
    )
    ..registerLazySingleton<HardwarePermissionService>(
      HardwarePermissionService.new,
    )
    ..registerLazySingleton<RfidRepository>(WebRfidRepository.new)
    ..registerLazySingleton<WeatherService>(OpenMeteoWeatherService.new)
    ..registerLazySingleton<WeatherPreferencesService>(
      () => WeatherPreferencesService(
        preferences: prefs,
        weatherService: locator<WeatherService>(),
      ),
    )
    ..registerLazySingleton<WeatherAlertsService>(
      () => WeatherAlertsService(
        preferences: prefs,
        locationService: locator<WeatherPreferencesService>(),
      ),
    )
    ..registerLazySingleton<InicioDashboardService>(
      () => InicioDashboardService(
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
        agendaRepository: locator<AgendaRepository>(),
        locationRepository: locator<LocationRepository>(),
        perfilRepository: locator<PerfilRepository>(),
        reproductionRepository: locator<ReproductionRecordRepository>(),
      ),
    )
    ..registerLazySingleton<DashboardConfigRepository>(
      () => DashboardConfigRepository(prefs),
    )
    ..registerLazySingleton<LibraryRepository>(AssetLibraryRepository.new)
    ..registerLazySingleton<FinanceSummaryService>(
      () => FinanceSummaryService(
        finanzasRepository: locator<FinanzasRepository>(),
        animalRepository: locator<AnimalRepository>(),
        costRepo: locator<CostRecordRepository>(),
        commercialRepo: locator<CommercialRecordRepository>(),
      ),
    )
    ..registerLazySingleton<ReportSummaryService>(
      () => ReportSummaryService(
        animalRepository: locator<AnimalRepository>(),
        reproductionRepository: locator<ReproductionRecordRepository>(),
        healthRepository: locator<HealthRecordRepository>(),
        movementRepository: locator<MovementRecordRepository>(),
      ),
    )
    ..registerLazySingleton<BackupStore>(() => WebBackupStore(store))
    ..registerLazySingleton<BackupService>(
      () => BackupService(
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
        agendaRepository: locator<AgendaRepository>(),
        workforceRepository: locator<WorkforceRepository>(),
        milkingRepository: locator<MilkingRepository>(),
        backupStore: locator<BackupStore>(),
        statusPrefs: prefs,
      ),
    )
    ..registerLazySingleton<CloudBackupRepository>(
      () => const UnavailableCloudBackupRepository(),
    )
    ..registerLazySingleton<CloudBackupService>(
      () => CloudBackupService(
        backupService: locator<BackupService>(),
        repository: locator<CloudBackupRepository>(),
      ),
    )
    ..registerLazySingleton<ExportService>(() => ExportService(const []))
    ..registerLazySingleton<AssistantGateway>(ReadOnlyAssistantGateway.new)
    ..registerLazySingleton<AnimalIdentificationService>(
      AnimalIdentificationService.new,
    )
    ..registerLazySingleton<ProjectionService>(ProjectionService.new)
    ..registerLazySingleton<MexicoReportService>(MexicoReportService.new)
    ..registerLazySingleton<SubscriptionService>(SubscriptionService.new)
    ..registerLazySingleton<FiscalProvider>(FacturapiSandboxProvider.new)
    ..registerLazySingleton<PaymentProvider>(StripeSandboxProvider.new)
    ..registerLazySingleton<SyncGateway>(() => const UnavailableSyncGateway())
    ..registerLazySingleton<SyncEngine>(
      () => SyncEngine(store: store, gateway: locator<SyncGateway>()),
    );
  _registerWebPlanSlices();
  await locator<FarmMigrationService>().ensureDefaultFarm();
}

void _registerWebPlanSlices() {
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
