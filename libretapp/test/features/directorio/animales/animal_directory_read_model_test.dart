import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_directory_read_model.dart';

void main() {
  test('coalesces reads and derives counts for a 2,000 animal herd', () async {
    final animals = List.generate(2000, _animal);
    var loadCount = 0;
    final cache = AnimalDirectoryReadModelCache(() async {
      loadCount++;
      await Future<void>.delayed(Duration.zero);
      return animals;
    });

    final results = await Future.wait([cache.read(), cache.read()]);
    expect(loadCount, 1);
    expect(identical(results[0], results[1]), isTrue);
    expect(results.first.animals, hasLength(2000));
    expect(results.first.stageCounts[LifeStage.cow], 2000);
    expect(results.first.taxonomyCounts[Species.cattle]![LifeStage.cow], 2000);

    cache.invalidate();
    await cache.read();
    expect(loadCount, 2);
  });

  test('does not cache a pending response after invalidation', () async {
    final oldRead = Completer<List<AnimalEntity>>();
    var loadCount = 0;
    final cache = AnimalDirectoryReadModelCache(() {
      loadCount++;
      return loadCount == 1
          ? oldRead.future
          : Future<List<AnimalEntity>>.value(const []);
    });

    final stale = cache.read();
    cache.invalidate();
    final fresh = await cache.read();
    oldRead.complete(const []);
    await stale;
    expect(identical(await cache.read(), fresh), isTrue);
    expect(loadCount, 2);
  });

  test('counts companion life stages across species', () {
    final cattleCompanion = _animal(
      1,
    ).copyWith(productionPurpose: ProductionPurpose.companion);
    final felineCompanion = _animal(2).copyWith(
      species: Species.feline,
      lifeStage: LifeStage.cat,
      productionPurpose: ProductionPurpose.companion,
    );
    final productiveCow = _animal(3);
    final model = AnimalDirectoryReadModel([
      cattleCompanion,
      felineCompanion,
      productiveCow,
    ]);

    expect(model.companionStageCounts, {LifeStage.cow: 1, LifeStage.cat: 1});
  });
}

AnimalEntity _animal(int index) {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: 'animal-$index',
    earTagNumber: 'TAG-$index',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Generic',
    birthDate: DateTime(2022, 1, 1),
    ageMonths: 24,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.growth,
    productionSystem: ProductionSystem.intensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}
