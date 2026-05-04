/// core › services › prefs_keys — SharedPreferences key constants.
library;

/// Centralises all [SharedPreferences] key strings to avoid magic strings.
class PrefsKeys {
  const PrefsKeys._();

  static const animalsHash = 'animals.hash';
  static const animalsLastSync = 'animals.lastSync';
  static const eventsStorage = 'events.storage';
  static const eventsInitialPurgeV1Done = 'events.initialPurge.v1.done';
  static const appLanguage = 'app.language';
  static const appTheme = 'app.theme';
  static const animalWizardDraft = 'animal.wizard.draft';
}
