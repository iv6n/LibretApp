import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/first_backup_suggestion.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async => locator.reset());

  test('offers the backup link only once after registration', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    locator.registerSingleton<SharedPrefsService>(prefs);

    expect(await consumeFirstBackupSuggestion(), isTrue);
    expect(await consumeFirstBackupSuggestion(), isFalse);
    expect(prefs.getBool(PrefsKeys.firstBackupSuggestionShown), isTrue);
  });

  test('does not offer the link when a backup already exists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    locator.registerSingleton<SharedPrefsService>(prefs);
    await prefs.setDateTime(PrefsKeys.lastLocalBackup, DateTime(2026, 10, 29));

    expect(await consumeFirstBackupSuggestion(), isFalse);
    expect(prefs.getBool(PrefsKeys.firstBackupSuggestionShown), isNull);
  });
}
