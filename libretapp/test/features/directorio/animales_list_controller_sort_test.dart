import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/view/animales_list_controller.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';

void main() {
  group('AnimalesListController sorting', () {
    late AnimalesListController controller;

    setUp(() {
      controller = AnimalesListController(
        locationRepository: IsarLocationRepository(IsarDatabase()),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('sorts the whole directory by latest activity', () {
      final normalRecent = _buildAnimal(
        uuid: 'normal-recent',
        earTagNumber: 'Z-200',
        riskLevel: RiskLevel.low,
        healthStatus: HealthStatus.good,
        lastUpdateDate: DateTime(2025, 1, 3),
      );
      final poorOld = _buildAnimal(
        uuid: 'poor-old',
        earTagNumber: 'A-100',
        riskLevel: RiskLevel.low,
        healthStatus: HealthStatus.poor,
        lastUpdateDate: DateTime(2025, 1, 1),
      );
      final poorRecent = _buildAnimal(
        uuid: 'poor-recent',
        earTagNumber: 'B-101',
        riskLevel: RiskLevel.low,
        healthStatus: HealthStatus.poor,
        lastUpdateDate: DateTime(2025, 1, 2),
      );

      final sorted = controller.applyFilters([
        normalRecent,
        poorOld,
        poorRecent,
      ]);

      expect(
        sorted.map((a) => a.uuid),
        equals(['normal-recent', 'poor-recent', 'poor-old']),
      );
    });

    test('does not let an older alert outrank newer activity', () {
      final observed = _buildAnimal(
        uuid: 'observed',
        earTagNumber: 'OBS-1',
        underObservation: true,
        riskLevel: RiskLevel.medium,
        healthStatus: HealthStatus.fair,
        lastUpdateDate: DateTime(2025, 1, 1),
      );
      final poor = _buildAnimal(
        uuid: 'poor',
        earTagNumber: 'POOR-1',
        underObservation: false,
        riskLevel: RiskLevel.medium,
        healthStatus: HealthStatus.poor,
        lastUpdateDate: DateTime(2025, 1, 4),
      );

      final sorted = controller.applyFilters([poor, observed]);

      expect(sorted.first.uuid, 'poor');
    });

    test('uses ear tag and then UUID as stable tie-breakers', () {
      final samePriorityDateB = _buildAnimal(
        uuid: 'tie-b',
        earTagNumber: 'B-002',
        lastUpdateDate: DateTime(2025, 1, 1),
      );
      final samePriorityDateA = _buildAnimal(
        uuid: 'tie-a',
        earTagNumber: 'A-001',
        lastUpdateDate: DateTime(2025, 1, 1),
      );
      final emptyTagWithVisual = _buildAnimal(
        uuid: 'tie-visual',
        earTagNumber: ' ',
        visualId: 'AA-visual',
        lastUpdateDate: DateTime(2025, 1, 1),
      );

      final sorted = controller.applyFilters([
        samePriorityDateB,
        samePriorityDateA,
        emptyTagWithVisual,
      ]);

      expect(
        sorted.map((a) => a.uuid),
        equals(['tie-visual', 'tie-a', 'tie-b']),
      );
    });

    test('filters pending ear tags independently from health attention', () {
      final pending = _buildAnimal(
        uuid: 'pending',
        earTagNumber: '',
        species: Species.cattle,
        requiresAttention: false,
      );
      final optionalIdentification = _buildAnimal(
        uuid: 'canine-without-id',
        earTagNumber: '',
        species: Species.canine,
        requiresAttention: true,
      );
      final tagged = _buildAnimal(
        uuid: 'tagged',
        earTagNumber: 'B-123',
        species: Species.cattle,
      );

      controller.setOnlyPendingEarTag(true);
      final filtered = controller.applyFilters([
        pending,
        optionalIdentification,
        tagged,
      ]);

      expect(filtered.map((animal) => animal.uuid), ['pending']);
    });

    test(
      'sanitary pending filter includes each unvaccinated or observed animal once',
      () {
        final unvaccinated = _buildAnimal(
          uuid: 'unvaccinated',
          earTagNumber: 'unvaccinated',
          vaccinated: false,
        );
        final observed = _buildAnimal(
          uuid: 'observed',
          earTagNumber: 'observed',
          vaccinated: true,
          underObservation: true,
        );
        final both = _buildAnimal(
          uuid: 'both',
          earTagNumber: 'both',
          vaccinated: false,
          underObservation: true,
        );
        final healthy = _buildAnimal(
          uuid: 'healthy',
          earTagNumber: 'healthy',
          vaccinated: true,
        );

        controller.setHealthFilter(AnimalHealthFilter.pending);

        expect(
          controller
              .applyFilters([unvaccinated, observed, both, healthy])
              .map((animal) => animal.uuid)
              .toSet(),
          {'unvaccinated', 'observed', 'both'},
        );
      },
    );

    test(
      'unvaccinated filter excludes observed animals with vaccination recorded',
      () {
        final unvaccinated = _buildAnimal(
          uuid: 'unvaccinated',
          earTagNumber: 'unvaccinated',
          vaccinated: false,
        );
        final observed = _buildAnimal(
          uuid: 'observed',
          earTagNumber: 'observed',
          vaccinated: true,
          underObservation: true,
        );

        controller.setHealthFilter(AnimalHealthFilter.unvaccinated);

        expect(
          controller.applyFilters([unvaccinated, observed]).map((a) => a.uuid),
          ['unvaccinated'],
        );
      },
    );

    test('filters selected species and its available stages together', () {
      final cattle = _buildAnimal(
        uuid: 'cattle',
        earTagNumber: 'C-1',
        species: Species.cattle,
      );
      final goat = _buildAnimal(
        uuid: 'goat',
        earTagNumber: 'G-1',
        species: Species.goat,
        lifeStage: LifeStage.goat,
      );
      final goatKid = _buildAnimal(
        uuid: 'goat-kid',
        earTagNumber: 'G-2',
        species: Species.goat,
        lifeStage: LifeStage.kid,
      );

      controller.loadTaxonomy([cattle, goat, goatKid]);
      controller.setSpecies(Species.goat);
      controller.setStages({LifeStage.goat});

      final filtered = controller.applyFilters([cattle, goat, goatKid]);

      expect(filtered.map((animal) => animal.uuid), ['goat']);
    });

    test(
      'companion filter includes companion animals across species',
      () async {
        final cattleCompanion = _buildAnimal(
          uuid: 'cattle-companion',
          earTagNumber: 'C-2',
          species: Species.cattle,
        ).copyWith(productionPurpose: ProductionPurpose.companion);
        final felineCompanion = _buildAnimal(
          uuid: 'feline-companion',
          earTagNumber: 'F-1',
          species: Species.feline,
          lifeStage: LifeStage.cat,
        ).copyWith(productionPurpose: ProductionPurpose.companion);
        final productiveCattle = _buildAnimal(
          uuid: 'productive-cattle',
          earTagNumber: 'C-3',
          species: Species.cattle,
        );

        await controller.loadTaxonomy([
          cattleCompanion,
          felineCompanion,
          productiveCattle,
        ]);
        controller.setCompanion(true);

        expect(
          controller.state.companionStageCounts.values.reduce((a, b) => a + b),
          2,
        );
        expect(
          controller
              .applyFilters([
                cattleCompanion,
                felineCompanion,
                productiveCattle,
              ])
              .map((animal) => animal.uuid),
          ['cattle-companion', 'feline-companion'],
        );

        controller.setSpecies(Species.cattle);
        expect(controller.state.selectedCompanion, isFalse);
        expect(controller.state.selectedStages, isEmpty);
      },
    );
  });
}

AnimalEntity _buildAnimal({
  required String uuid,
  required String earTagNumber,
  String? visualId,
  Species species = Species.cattle,
  bool underObservation = false,
  bool vaccinated = false,
  bool requiresAttention = false,
  RiskLevel riskLevel = RiskLevel.low,
  HealthStatus healthStatus = HealthStatus.good,
  DateTime? lastUpdateDate,
  LifeStage lifeStage = LifeStage.cow,
}) {
  final timestamp = lastUpdateDate ?? DateTime(2025, 1, 1);

  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTagNumber,
    visualId: visualId,
    species: species,
    category: Category.cow,
    lifeStage: lifeStage,
    sex: Sex.female,
    breed: 'Generic',
    birthDate: DateTime(2023, 1, 1),
    ageMonths: 24,
    healthStatus: healthStatus,
    vaccinated: vaccinated,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.growth,
    productionSystem: ProductionSystem.intensive,
    underObservation: underObservation,
    requiresAttention: requiresAttention,
    riskLevel: riskLevel,
    gallery: const [],
    synced: true,
    creationDate: DateTime(2025, 1, 1),
    lastUpdateDate: timestamp,
  );
}
