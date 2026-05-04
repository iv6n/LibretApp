/// core › di › injection — GetIt service locator setup.
///
/// Call [setupLocator] once at startup to register all dependencies.
library;

import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:libretapp/core/native/ffi/libret_native_bridge.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:libretapp/core/security/services/auth_service.dart';
import 'package:libretapp/core/security/services/crypto_stub_service.dart';
import 'package:libretapp/core/security/services/default_key_provider_service.dart';
import 'package:libretapp/core/security/services/native_crypto_service.dart';
import 'package:libretapp/core/security/services/prefs_secure_store_service.dart';
import 'package:libretapp/core/security/services/secure_logger_service.dart';
import 'package:libretapp/core/security/services/token_store_service.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/theme_repository.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';
import 'package:libretapp/features/eventos/data/eventos_reminder_sync_service.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
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

  locator
    ..registerSingleton<IsarDatabase>(isarDatabase)
    ..registerSingleton<SharedPrefsService>(
      SharedPrefsService(sharedPreferences),
    )
    ..registerLazySingleton<SensitiveLoggerPort>(SecureLoggerService.new)
    ..registerLazySingleton<SecureStorePort>(
      () => PrefsSecureStoreService(locator<SharedPrefsService>()),
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
      () => AuthService(
        tokenPort: locator<TokenPort>(),
        logger: locator<SensitiveLoggerPort>(),
      ),
    )
    ..registerLazySingleton<ThemeRepository>(
      () => ThemeRepository(locator<SharedPrefsService>()),
    )
    ..registerLazySingleton<AnimalRemoteDataSource>(AnimalApiMock.new)
    ..registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryIsar(
        locator<IsarDatabase>(),
        locator<SharedPrefsService>(),
        locator<AnimalRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<LotesRepository>(
      () => LotesRepositoryIsar(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<LocationRepository>(
      () => IsarLocationRepository(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<EventosRepository>(
      () => EventosRepositoryImpl(locator<SharedPrefsService>()),
    )
    ..registerLazySingleton<EventosReminderSyncService>(
      () => EventosReminderSyncService(
        animalRepository: locator<AnimalRepository>(),
        eventosRepository: locator<EventosRepository>(),
      ),
    )
    ..registerLazySingleton<InicioDashboardService>(
      () => InicioDashboardService(
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
        eventosRepository: locator<EventosRepository>(),
        locationRepository: locator<LocationRepository>(),
        perfilRepository: locator<PerfilRepository>(),
      ),
    )
    ..registerLazySingleton<PerfilRepository>(() => PerfilRepositoryImpl())
    ..registerLazySingleton<FinanzasRepository>(
      () => IsarFinanzasRepository(locator<IsarDatabase>()),
    );
}
