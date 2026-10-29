import 'package:libretapp/features/agenda/data/agenda_model.dart';

/// Entries without a known owner are user data. Never infer ownership from
/// the generic `auto:` prefix: external schedulers and legacy app surfaces use
/// that same prefix.
bool isGeneratorManagedAgendaEntry(AgendaEntry entry) {
  if (entry.sourceType == 'manual' || entry.sourceType == 'lite') return false;
  if (entry.sourceType != null) {
    return const {
      'care',
      'health',
      'reproduction',
      'cropTask',
      'cropCycle',
      'locationPlan',
    }.contains(entry.sourceType);
  }
  return const [
    'auto:care:',
    'auto:health:',
    'auto:repro:',
    'auto:location-maintenance:',
    'auto:crop-task:',
    'auto:crop-watering:',
    'auto:crop-harvest:',
  ].any(entry.id.startsWith);
}
