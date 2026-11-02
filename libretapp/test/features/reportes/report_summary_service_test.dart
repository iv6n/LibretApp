import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/reportes/domain/report_summary_service.dart';

void main() {
  test('counts each animal with a sanitary pending only once', () async {
    final service = ReportSummaryService(
      animalRepository: _Animals([
        _animal('both', vaccinated: false, underObservation: true),
        _animal('unvaccinated', vaccinated: false),
        _animal('observed', vaccinated: true, underObservation: true),
        _animal('healthy', vaccinated: true),
      ]),
      reproductionRepository: _Reproduction(),
      healthRepository: _Health(),
      movementRepository: _Movements(),
    );

    final summary = await service.loadSummary();

    expect(summary.healthAlertsCount, 3);
    expect(summary.unvaccinatedCount, 2);
    expect(summary.underObservationCount, 2);
  });
}

AnimalEntity _animal(
  String uuid, {
  required bool vaccinated,
  bool underObservation = false,
}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: uuid,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Criollo',
    birthDate: DateTime(2023, 1, 1),
    ageMonths: 36,
    healthStatus: HealthStatus.good,
    vaccinated: vaccinated,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.growth,
    productionSystem: ProductionSystem.intensive,
    underObservation: underObservation,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

class _Animals implements AnimalRepository {
  _Animals(this.animals);
  final List<AnimalEntity> animals;

  @override
  Future<List<AnimalEntity>> getAll() async => animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reproduction implements ReproductionRecordRepository {
  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
  getUpcomingCalvings(DateTime from, DateTime to) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Health implements HealthRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Movements implements MovementRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
