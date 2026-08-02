/// core › services › prefs_keys — SharedPreferences key constants.
library;

/// Centralises all [SharedPreferences] key strings to avoid magic strings.
class PrefsKeys {
  const PrefsKeys._();

  static const animalsHash = 'animals.hash';
  static const animalsLastSync = 'animals.lastSync';
  static const eventsStorage = 'events.storage';
  static const eventsInitialPurgeV1Done = 'events.initialPurge.v1.done';
  static const agendaIsarMigrationV1Done = 'agenda.isar.migration.v1.done';
  static const appLanguage = 'app.language';
  static const appTheme = 'app.theme';
  static const animalWizardDraft = 'animal.wizard.draft';

  /// Versioned so a rule-set change (`DefaultCareRules.version`) reaches
  /// herds that already ran an earlier preload, without resurrecting rules
  /// the breeder retired in between.
  static String careDefaultsPreloaded(int version) =>
      'care.defaults.preloaded.v$version';

  /// Version of the installed demo scenario (`demoScenarioVersion`), or
  /// absent if it was never installed. `DemoScenarioService.install` compares
  /// against this so a plain repeat call is a no-op that never touches a
  /// user's edits to demo records — only `reset: true` forces a reseed.
  static const demoScenarioInstalledVersion = 'demo.scenario.installedVersion';
}
