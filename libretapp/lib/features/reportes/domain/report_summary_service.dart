/// features › reportes › domain › report_summary_service — builds ranch report aggregates.
library;

import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/reportes/data/report_summary.dart';

class ReportSummaryService {
  ReportSummaryService({
    required AnimalRepository animalRepository,
    required ReproductionRecordRepository reproductionRepository,
    required HealthRecordRepository healthRepository,
    required MovementRecordRepository movementRepository,
  }) : _animalRepository = animalRepository,
       _reproductionRepository = reproductionRepository,
       _healthRepository = healthRepository,
       _movementRepository = movementRepository;

  final AnimalRepository _animalRepository;
  final ReproductionRecordRepository _reproductionRepository;
  final HealthRecordRepository _healthRepository;
  final MovementRecordRepository _movementRepository;

  Future<ReportSummary> loadSummary() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final animals = await _animalRepository.getAll();

    final speciesTotals = <Species, int>{};
    final categoryTotals = <Category, int>{};
    var unvaccinated = 0;
    var underObservation = 0;

    for (final animal in animals) {
      speciesTotals.update(animal.species, (c) => c + 1, ifAbsent: () => 1);
      categoryTotals.update(animal.category, (c) => c + 1, ifAbsent: () => 1);
      if (!animal.vaccinated) unvaccinated++;
      if (animal.underObservation) underObservation++;
    }

    final bySpecies = speciesTotals.entries
        .map((e) => SpeciesCount(species: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final byCategory = categoryTotals.entries
        .map((e) => CategoryCount(category: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final calvingWindow = today.add(const Duration(days: 21));
    final calvingRaw = await _reproductionRepository.getUpcomingCalvings(
      today,
      calvingWindow,
    );
    final animalMap = {for (final a in animals) a.uuid: a};
    final upcomingCalvings =
        calvingRaw
            .map((c) {
              final animal = animalMap[c.animalUuid];
              if (animal == null) return null;
              return CalvingItem(
                animalUuid: c.animalUuid,
                animalTag: animal.earTagNumber,
                animalName: animal.customName,
                expectedDate: c.expectedCalvingDate,
                daysRemaining: c.expectedCalvingDate.difference(today).inDays,
              );
            })
            .whereType<CalvingItem>()
            .toList(growable: false)
          ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    final recentMovements = <RecentRecordItem>[];
    final recentRecords = <RecentRecordItem>[];

    for (final animal in animals) {
      final movements = await _movementRepository.getMovementRecords(
        animal.uuid,
      );
      for (final m in movements) {
        recentMovements.add(
          RecentRecordItem(
            title: 'Movimiento',
            subtitle: m.notes ?? '${m.reason.displayName} → ${m.toLocation}',
            date: m.date,
            animalTag: animal.earTagNumber,
            route: AppRoutes.animalDetallePath(animal.uuid),
          ),
        );
      }

      final health = await _healthRepository.getHealthRecords(animal.uuid);
      for (final h in health) {
        recentRecords.add(
          RecentRecordItem(
            title: h.type.displayName,
            subtitle: h.notes ?? animal.displayLabel,
            date: h.date,
            animalTag: animal.earTagNumber,
            route: AppRoutes.animalDetallePath(animal.uuid),
          ),
        );
      }
    }

    recentMovements.sort((a, b) => b.date.compareTo(a.date));
    recentRecords.sort((a, b) => b.date.compareTo(a.date));

    return ReportSummary(
      totalAnimals: animals.length,
      bySpecies: bySpecies,
      byCategory: byCategory,
      upcomingCalvings: upcomingCalvings,
      healthAlertsCount: unvaccinated + underObservation,
      unvaccinatedCount: unvaccinated,
      underObservationCount: underObservation,
      recentMovements: recentMovements.take(5).toList(growable: false),
      recentRecords: recentRecords.take(5).toList(growable: false),
      generatedAt: now,
    );
  }
}

extension on AnimalEntity {
  String get displayLabel =>
      customName?.isNotEmpty == true ? customName! : earTagNumber;
}
