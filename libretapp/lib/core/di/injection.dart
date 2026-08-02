/// core › di › injection — GetIt service locator setup.
///
/// Call [setupLocator] once at startup to register all dependencies.
///
/// Registration is split into one helper per domain purely for
/// readability — GetIt's `registerLazySingleton` only stores a factory, it
/// doesn't invoke it, so the *order* these helpers run in doesn't matter as
/// long as they all complete (which they do, synchronously) before anything
/// is actually resolved via `locator<T>()`.
library;

import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:libretapp/core/backup/cloud_backup_service.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/backup/supabase_cloud_backup_repository.dart';
import 'package:libretapp/core/backup/supabase_config.dart';
import 'package:libretapp/core/backup/unavailable_cloud_backup_repository.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/core/native/ffi/libret_native_bridge.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:libretapp/core/security/services/auth_service.dart';
import 'package:libretapp/core/security/services/crypto_stub_service.dart';
import 'package:libretapp/core/security/services/default_key_provider_service.dart';
import 'package:libretapp/core/security/services/native_crypto_service.dart';
import 'package:libretapp/core/security/services/prefs_key_value_store_service.dart';
import 'package:libretapp/core/security/services/secure_logger_service.dart';
import 'package:libretapp/core/security/services/supabase_auth_service.dart';
import 'package:libretapp/core/security/services/token_store_service.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/animal_excel_import_service.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/theme_repository.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/eventos_export_sheet.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animales_export_sheet.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/ubicaciones_export_sheet.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_agenda_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_workforce_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/location_enum_migration_service.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_shared_prefs_repository.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/reportes/domain/report_summary_service.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/milking/infrastructure/milking_repository_isar.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/commercial_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/cost_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/care_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/production_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

const _allowInsecureCryptoInRelease = bool.fromEnvironment(
  'LIBRET_ALLOW_INSECURE_CRYPTO_IN_RELEASE',
  defaultValue: false,
);
const _resetLocalDbOnStartup = bool.fromEnvironment(
  'LIBRET_RESET_LOCAL_DB',
  defaultValue: false,
);

bool _isProductionReadyCoreVersion(String version) {
  // Temporary policy: reject pre-1.x core versions in release builds.
  return !version.startsWith('libret-core/0.');
}

Future<void> setupLocator() async {
  final isarDatabase = IsarDatabase();
  await isarDatabase.initialize();

  if (_resetLocalDbOnStartup) {
    if (kReleaseMode) {
      LoggerService.w(
        'LIBRET_RESET_LOCAL_DB ignorado en release por seguridad',
        tag: 'DI',
      );
    } else {
      LoggerService.w(
        'LIBRET_RESET_LOCAL_DB activo: limpiando base local completa',
        tag: 'DI',
      );
      await isarDatabase.clearAllCollections();
    }
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  _registerInfrastructure(isarDatabase, sharedPreferences);
  _registerSecurity();
  _registerDirectorioAnimales();
  _registerDirectorioLotes();
  _registerUbicaciones(sharedPreferences);
  _registerAgenda();
  _registerMilkingFinanzas();
  _registerBackupExport();
  _registerInicioPerfilReportes();
  _registerDemo();
}

void _registerInfrastructure(
  IsarDatabase isarDatabase,
  SharedPreferences sharedPreferences,
) {
  locator
    ..registerSingleton<IsarDatabase>(isarDatabase)
    ..registerSingleton<SharedPrefsService>(
      SharedPrefsService(sharedPreferences),
    )
    ..registerLazySingleton<ThemeRepository>(
      () => ThemeRepository(locator<SharedPrefsService>()),
    );
}

void _registerSecurity() {
  locator
    ..registerLazySingleton<SensitiveLoggerPort>(SecureLoggerService.new)
    ..registerLazySingleton<SecureStorePort>(
      () => PrefsKeyValueStoreService(locator<SharedPrefsService>()),
    )
    ..registerLazySingleton<KeyProviderPort>(DefaultKeyProviderService.new)
    ..registerLazySingleton<CryptoPort>(() {
      try {
        final bridge = LibretNativeBridge.create();
        final version = bridge.getCoreVersion();

        if (kReleaseMode && !_allowInsecureCryptoInRelease) {
          if (!_isProductionReadyCoreVersion(version)) {
            throw StateError(
              'Release build rejected insecure native crypto version: $version',
            );
          }
        }

        LoggerService.i('Crypto backend: native ($version)', tag: 'Security');
        return NativeCryptoService(bridge);
      } catch (e) {
        if (kReleaseMode && !_allowInsecureCryptoInRelease) {
          throw StateError(
            'Release build requires production native crypto backend. Cause: $e',
          );
        }

        LoggerService.w('Crypto backend fallback to stub: $e', tag: 'Security');
        return CryptoStubService();
      }
    })
    ..registerLazySingleton<TokenPort>(
      () => TokenStoreService(
        secureStore: locator<SecureStorePort>(),
        cryptoPort: locator<CryptoPort>(),
        keyProvider: locator<KeyProviderPort>(),
      ),
    )
    ..registerLazySingleton<AuthPort>(
      () => SupabaseConfig.isConfigured
          ? SupabaseAuthService(
              client: Supabase.instance.client,
              tokenPort: locator<TokenPort>(),
              logger: locator<SensitiveLoggerPort>(),
            )
          : AuthService(
              tokenPort: locator<TokenPort>(),
              logger: locator<SensitiveLoggerPort>(),
            ),
    );
}

void _registerDirectorioAnimales() {
  locator
    ..registerLazySingleton<AnimalRemoteDataSource>(
      kDebugMode ? AnimalApiMock.new : _NoOpAnimalRemoteDataSource.new,
    )
    ..registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryIsar(
        locator<IsarDatabase>(),
        locator<SharedPrefsService>(),
        locator<AnimalRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<AnimalExcelImportService>(
      () => AnimalExcelImportService(
        animalRepository: locator<AnimalRepository>(),
      ),
    )
    ..registerLazySingleton<WeightRecordRepository>(
      () => WeightRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<HealthRecordRepository>(
      () => HealthRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<ProductionRecordRepository>(
      () => ProductionRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<ReproductionRecordRepository>(
      () => ReproductionRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<CommercialRecordRepository>(
      () => CommercialRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<MovementRecordRepository>(
      () => MovementRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<CostRecordRepository>(
      () => CostRecordRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<CareRepository>(
      () => CareRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<CareCalendarService>(
      () => CareCalendarService(locator<CareRepository>()),
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
    );
}

void _registerDirectorioLotes() {
  locator.registerLazySingleton<LotesRepository>(
    () => LotesRepositoryIsar(locator<IsarDatabase>()),
  );
}

void _registerUbicaciones(SharedPreferences sharedPreferences) {
  locator
    ..registerLazySingleton<LocationRepository>(
      () => IsarLocationRepository(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<LocationEnumMigrationService>(
      () => LocationEnumMigrationService(
        isar: locator<IsarDatabase>().isar,
        prefs: sharedPreferences,
      ),
    );
}

void _registerAgenda() {
  locator
    ..registerLazySingleton<AgendaRepository>(
      () => IsarAgendaRepository(
        locator<IsarDatabase>(),
        locator<SharedPrefsService>(),
      ),
    )
    ..registerLazySingleton<WorkforceRepository>(
      () => IsarWorkforceRepository(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<AgendaReminderSyncService>(
      () => AgendaReminderSyncService(
        animalRepository: locator<AnimalRepository>(),
        agendaRepository: locator<AgendaRepository>(),
        healthRepo: locator<HealthRecordRepository>(),
        reproductionRepo: locator<ReproductionRecordRepository>(),
        careRepo: locator<CareRepository>(),
        careCalendarService: locator<CareCalendarService>(),
      ),
    );
}

void _registerDemo() {
  locator.registerLazySingleton<DemoScenarioService>(
    () => DemoScenarioService(
      animalRepository: locator<AnimalRepository>(),
      lotesRepository: locator<LotesRepository>(),
      locationRepository: locator<LocationRepository>(),
      weightRepository: locator<WeightRecordRepository>(),
      healthRepository: locator<HealthRecordRepository>(),
      reproductionRepository: locator<ReproductionRecordRepository>(),
      productionRepository: locator<ProductionRecordRepository>(),
      movementRepository: locator<MovementRecordRepository>(),
      commercialRepository: locator<CommercialRecordRepository>(),
      costRepository: locator<CostRecordRepository>(),
      careRepository: locator<CareRepository>(),
      careCalendarService: locator<CareCalendarService>(),
      milkingRepository: locator<MilkingRepository>(),
      finanzasRepository: locator<FinanzasRepository>(),
      agendaRepository: locator<AgendaRepository>(),
      workforceRepository: locator<WorkforceRepository>(),
      perfilRepository: locator<PerfilRepository>(),
      agendaReminderSyncService: locator<AgendaReminderSyncService>(),
      prefs: locator<SharedPrefsService>(),
    ),
  );
}

void _registerMilkingFinanzas() {
  locator
    ..registerLazySingleton<MilkingRepository>(
      () => MilkingRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<FinanzasRepository>(
      () => IsarFinanzasRepository(locator<IsarDatabase>()),
    );
}

void _registerBackupExport() {
  locator
    ..registerLazySingleton<BackupStore>(
      () => IsarBackupStore(
        database: locator<IsarDatabase>(),
        perfilRepository: locator<PerfilRepository>(),
      ),
    )
    ..registerLazySingleton<BackupService>(
      () => BackupService(
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
        agendaRepository: locator<AgendaRepository>(),
        workforceRepository: locator<WorkforceRepository>(),
        milkingRepository: locator<MilkingRepository>(),
        backupStore: locator<BackupStore>(),
        fetchAllAnimalsIncludingArchived: () {
          final repo = locator<AnimalRepository>();
          return repo is AnimalRepositoryIsar
              ? repo.getAllIncludingArchived()
              : repo.getAll();
        },
      ),
    )
    ..registerLazySingleton<CloudBackupRepository>(
      () => SupabaseConfig.isConfigured
          ? SupabaseCloudBackupRepository(Supabase.instance.client)
          : const UnavailableCloudBackupRepository(),
    )
    ..registerLazySingleton<CloudBackupService>(
      () => CloudBackupService(
        backupService: locator<BackupService>(),
        repository: locator<CloudBackupRepository>(),
      ),
    )
    ..registerLazySingleton<ExportService>(
      () => ExportService(
        animalsSheet: AnimalesExportSheet(locator<AnimalRepository>()),
        ubicacionesSheet: UbicacionesExportSheet(locator<LocationRepository>()),
        eventosSheet: EventosExportSheet(
          agendaRepository: locator<AgendaRepository>(),
          workforceRepository: locator<WorkforceRepository>(),
        ),
      ),
    );
}

void _registerInicioPerfilReportes() {
  locator
    ..registerLazySingleton<WeatherService>(OpenMeteoWeatherService.new)
    ..registerLazySingleton<InicioDashboardService>(
      () => InicioDashboardService(
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
        agendaRepository: locator<AgendaRepository>(),
        locationRepository: locator<LocationRepository>(),
        perfilRepository: locator<PerfilRepository>(),
        reproductionRepository: locator<ReproductionRecordRepository>(),
        weatherService: locator<WeatherService>(),
      ),
    )
    ..registerLazySingleton<PerfilRepository>(
      () => PerfilSharedPrefsRepository(locator<SharedPrefsService>()),
    )
    ..registerLazySingleton<DashboardConfigRepository>(
      () => DashboardConfigRepository(locator<SharedPrefsService>()),
    )
    ..registerLazySingleton<LibraryRepository>(MockLibraryRepository.new)
    ..registerLazySingleton<ReportSummaryService>(
      () => ReportSummaryService(
        animalRepository: locator<AnimalRepository>(),
        reproductionRepository: locator<ReproductionRecordRepository>(),
        healthRepository: locator<HealthRecordRepository>(),
        movementRepository: locator<MovementRecordRepository>(),
      ),
    )
    ..registerLazySingleton<FinanceSummaryService>(
      () => FinanceSummaryService(
        finanzasRepository: locator<FinanzasRepository>(),
        animalRepository: locator<AnimalRepository>(),
        costRepo: locator<CostRecordRepository>(),
        commercialRepo: locator<CommercialRecordRepository>(),
      ),
    );
}

/// Production stub for [AnimalRemoteDataSource].
///
/// Remote sync is not yet implemented; returns an empty payload so the local
/// Isar repository operates offline-first without crashing.
final class _NoOpAnimalRemoteDataSource implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async {
    return RemoteAnimalPayload(
      animals: const [],
      hash: '',
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
