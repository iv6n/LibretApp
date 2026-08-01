/// features › directorio › animales › domain › repositories › care_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';

/// Persistence for the care calendar: the rules, what was actually done, and
/// what is coming up.
abstract class CareRepository {
  /// Rules the breeder currently applies. Retired ones are left out.
  Future<List<CareRule>> getRules();

  /// Ids of every rule ever stored, retired ones included.
  ///
  /// The default preload checks against this, not [getRules]: a rule the
  /// breeder retired must stay gone instead of reappearing on the next start.
  Future<Set<String>> getAllRuleIds();

  Future<void> saveRule(CareRule rule);

  /// Retires a rule instead of deleting it, so the default preload does not
  /// simply bring it back on the next start.
  Future<void> retireRule(String ruleId);

  Future<List<CareRecord>> getRecordsForAnimal(String animalUuid);

  /// The most recent record per rule for [animalUuid], which is what
  /// `CareScheduler.nextDue` needs to date the next task.
  Future<Map<String, CareRecord>> getLatestRecordsByRule(String animalUuid);

  Future<void> saveRecord(CareRecord record);

  /// Pending tasks due on or before [until], soonest first.
  Future<List<ScheduledCare>> getPending({DateTime? until});

  Future<List<ScheduledCare>> getPendingForAnimal(String animalUuid);

  /// Writes the schedule, replacing any previous entry with the same id.
  Future<void> saveSchedules(List<ScheduledCare> schedules);

  Future<void> markDone(String scheduleId);

  /// Drops the auto-generated tasks of an animal before regenerating them, so
  /// stale due dates do not pile up. Tasks the breeder created by hand stay.
  Future<void> clearGeneratedFor(String animalUuid);
}
