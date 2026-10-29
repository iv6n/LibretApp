import 'offline_journey_test.dart' as journey;

/// Runs the same real Isar/photo/restore/finance regressions for the connected
/// flavor without configuring SMS or a remote account.
void main() => journey.runNativeJourneyTests(connected: true);
