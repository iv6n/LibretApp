/// core › demo › builders › demo_milking — milking sessions/entries for the
/// demo herd.
///
/// 16 days of morning/evening sessions (within the 14–21 day range asked
/// for), only for cows that are actually eligible to be milked: active
/// bovine females that are not dry. The day-to-day volume "variation" is a
/// plain deterministic formula (`d % 3`), never `Random` — the whole
/// scenario has to reproduce byte-identical on every install.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';

class DemoMilkingResult {
  const DemoMilkingResult({required this.sessions, required this.entries});
  final List<MilkingSession> sessions;
  final List<MilkingEntry> entries;
}

const int demoMilkingDays = 16;

/// Cuernitos is under an active health withdrawal for the most recent days
/// of the scenario (see `demo_health.dart`) — she is excluded from every
/// session inside that window, and present in the older ones, so the
/// exclusion reads as a real, current event rather than a permanent one.
const int _cuernitosWithdrawalWindowDays = 5;

List<_DemoMilkedCow> _milkedCows() => const [
  _DemoMilkedCow(slug: aniPrietaSlug, baseMilliliters: 10500),
  _DemoMilkedCow(slug: aniWeraSlug, baseMilliliters: 9800),
  _DemoMilkedCow(slug: aniNancySlug, baseMilliliters: 11200),
  _DemoMilkedCow(slug: aniCuernitosSlug, baseMilliliters: 9400),
];

class _DemoMilkedCow {
  const _DemoMilkedCow({required this.slug, required this.baseMilliliters});
  final String slug;
  final int baseMilliliters;
}

DemoMilkingResult buildDemoMilking({required DateTime reference}) {
  final cows = _milkedCows();
  final sessions = <MilkingSession>[];
  final entries = <MilkingEntry>[];

  for (var d = demoMilkingDays - 1; d >= 0; d--) {
    final day = daysBefore(reference, d);
    for (final shift in [MilkingShift.morning, MilkingShift.evening]) {
      final isLatest = d == 0 && shift == MilkingShift.evening;
      final occurredAt = DateTime(
        day.year,
        day.month,
        day.day,
        shift == MilkingShift.morning ? 6 : 18,
      );
      final sessionSlug = 'd$d-${shift.name}';
      final sessionUuid = demoId('milking-session', sessionSlug);

      sessions.add(
        MilkingSession(
          uuid: sessionUuid,
          occurredAt: occurredAt,
          shift: shift,
          status: isLatest ? MilkingStatus.draft : MilkingStatus.completed,
          createdAt: occurredAt,
          updatedAt: occurredAt,
          notes: 'Registro de demostración.',
        ),
      );

      // The latest session is left as an empty draft on purpose — "al menos
      // una sesión en borrador".
      if (isLatest) continue;

      for (final cow in cows) {
        if (cow.slug == aniCuernitosSlug &&
            d < _cuernitosWithdrawalWindowDays) {
          continue;
        }
        final variation =
            ((d % 3) - 1) * 250 + (shift == MilkingShift.evening ? -400 : 0);
        entries.add(
          MilkingEntry(
            uuid: demoId('milking-entry', '$sessionSlug-${cow.slug}'),
            sessionUuid: sessionUuid,
            animalUuid: demoAnimalUuid(cow.slug),
            volumeMilliliters: cow.baseMilliliters + variation,
            createdAt: occurredAt,
            updatedAt: occurredAt,
          ),
        );
      }
    }
  }

  return DemoMilkingResult(sessions: sessions, entries: entries);
}
