/// core › demo › demo_scenario_version — version stamp for the demo scenario.
library;

/// Bumped whenever the shape of the demo scenario changes in a way that
/// should reach installs that already ran an earlier version.
///
/// [DemoScenarioService.install] compares this against the version persisted
/// in `SharedPreferences` (see `PrefsKeys.demoScenarioInstalledVersion`) and
/// only re-runs the builders when the persisted value is behind, or when the
/// caller explicitly asks for `reset: true`.
const int demoScenarioVersion = 1;
