import 'package:get_it/get_it.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final isarDatabase = IsarDatabase();
  await isarDatabase.initialize();
  final sharedPreferences = await SharedPreferences.getInstance();

  locator
    ..registerSingleton<IsarDatabase>(isarDatabase)
    ..registerSingleton<SharedPrefsService>(
      SharedPrefsService(sharedPreferences),
    )
    ..registerLazySingleton<AnimalRemoteDataSource>(AnimalApiMock.new)
    ..registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryIsar(
        locator<IsarDatabase>(),
        locator<SharedPrefsService>(),
        locator<AnimalRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<LocationRepository>(
      () => IsarLocationRepository(locator<IsarDatabase>()),
    )
    ..registerLazySingleton<EventosRepository>(() => EventosRepositoryImpl())
    ..registerLazySingleton<PerfilRepository>(() => PerfilRepositoryImpl());
}
