import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

void main() {
  test(
    'adds one actionable task for compatible animals without a tag',
    () async {
      final service = InicioDashboardService(
        animalRepository: _AnimalRepo([
          _animal(uuid: 'pending', species: Species.cattle, earTag: ''),
          _animal(uuid: 'optional', species: Species.canine, earTag: ''),
          _animal(uuid: 'tagged', species: Species.cattle, earTag: 'B-1'),
        ]),
        lotesRepository: _LotesRepo(),
        agendaRepository: _AgendaRepo(),
        locationRepository: _LocationRepo(),
        perfilRepository: _PerfilRepo(),
        reproductionRepository: _ReproductionRepo(),
        weatherService: _Weather(),
      );

      final dashboard = await service.loadDashboard();
      final task = dashboard.tasks.singleWhere(
        (item) => item.title == 'Asignar aretes pendientes',
      );

      expect(task.message, contains('1 animal requiere'));
      expect(
        task.targetRoute,
        '${AppRoutes.directorio}?tab=animales&pendingEarTag=true',
      );
      expect(
        dashboard.tasks.any((item) => item.title == 'Sin pendientes criticos'),
        isFalse,
      );
    },
  );
}

AnimalEntity _animal({
  required String uuid,
  required Species species,
  required String earTag,
}) {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTag,
    species: species,
    category: species == Species.canine ? Category.work : Category.cow,
    lifeStage: species == Species.canine ? LifeStage.workingDog : LifeStage.cow,
    sex: Sex.female,
    breed: 'Desconocido',
    birthDate: DateTime(2023, 1, 1),
    ageMonths: 24,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

class _AnimalRepo implements AnimalRepository {
  _AnimalRepo(this.animals);
  final List<AnimalEntity> animals;

  @override
  Future<List<AnimalEntity>> getAll() async => animals;

  @override
  Future<Map<String, dynamic>> getStatistics() async => {
    'total': animals.length,
    'attention': 0,
    'unsynced': 0,
  };

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LotesRepo implements LotesRepository {
  @override
  Future<List<LoteEntity>> getActiveLotes() async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AgendaRepo implements AgendaRepository {
  @override
  Future<List<AgendaEntry>> fetchEntries() async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LocationRepo implements LocationRepository {
  @override
  Future<List<LocationEntity>> getAll() async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PerfilRepo implements PerfilRepository {
  @override
  Future<Perfil> fetchPerfil() async => const Perfil(
    id: 'test',
    nombre: 'Ana',
    apellido: '',
    email: '',
    telefono: '',
    finca: 'Prueba',
    direccion: '',
  );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReproductionRepo implements ReproductionRecordRepository {
  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
  getUpcomingCalvings(DateTime from, DateTime to) async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Weather implements WeatherService {
  @override
  Future<WeatherData?> getCurrentWeather({
    required List<LocationEntity> locations,
    required String address,
  }) async => null;
}
