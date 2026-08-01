/// features › directorio › animales › domain › services › care_calendar_service — turns rules into due tasks.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_scheduler.dart';
import 'package:libretapp/features/directorio/animales/domain/services/default_care_rules.dart';

/// Decides which rules reach an animal and regenerates its pending tasks.
class CareCalendarService {
  const CareCalendarService(this._repository, {CareScheduler? scheduler})
    : _scheduler = scheduler ?? const CareScheduler();

  final CareRepository _repository;
  final CareScheduler _scheduler;

  /// Rules that apply to [animal], by species, sex and age.
  ///
  /// A rule with a null species or sex is deliberately open: "vitaminas" is
  /// worth scheduling whatever the breeder keeps.
  static List<CareRule> rulesFor(AnimalEntity animal, List<CareRule> rules) {
    return rules.where((rule) {
      if (rule.species != null && rule.species != animal.species) return false;
      if (rule.sex != null && rule.sex != animal.sex) return false;
      final min = rule.minAgeMonths;
      if (min != null && animal.ageMonths < min) return false;
      final max = rule.maxAgeMonths;
      if (max != null && animal.ageMonths > max) return false;
      return true;
    }).toList(growable: false);
  }

  /// Rebuilds the pending auto-generated tasks for [animal].
  ///
  /// Regenerating instead of appending keeps stale due dates from piling up
  /// when a rule's interval changes or a care is recorded late.
  Future<List<ScheduledCare>> regenerateFor(
    AnimalEntity animal, {
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final rules = rulesFor(animal, await _repository.getRules());
    if (rules.isEmpty) {
      await _repository.clearGeneratedFor(animal.uuid);
      return const [];
    }

    final lastByRule = await _repository.getLatestRecordsByRule(animal.uuid);

    final schedules = <ScheduledCare>[];
    for (final rule in rules) {
      final next = _scheduler.nextDue(
        animalId: animal.uuid,
        rule: rule,
        now: reference,
        lastRecord: lastByRule[rule.id],
      );
      if (next != null) schedules.add(next);
    }

    await _repository.clearGeneratedFor(animal.uuid);
    await _repository.saveSchedules(schedules);
    return schedules;
  }

  /// Writes the starter calendar the first time, and again whenever
  /// [DefaultCareRules.version] moves.
  ///
  /// Idempotent by design: rules are keyed by their id, so re-running updates
  /// them in place instead of duplicating. Rules the breeder retired stay
  /// retired, because `saveRule` only writes the ones missing from storage.
  Future<void> preloadDefaults({required bool alreadyLoaded}) async {
    if (alreadyLoaded) return;

    // Checked against every stored id, retired included, so a rule the breeder
    // switched off is not silently resurrected.
    final existing = await _repository.getAllRuleIds();
    for (final rule in DefaultCareRules.all()) {
      if (existing.contains(rule.id)) continue;
      await _repository.saveRule(rule);
    }
  }
}
