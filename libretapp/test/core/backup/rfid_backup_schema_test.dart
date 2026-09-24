import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';

void main() {
  test('current schema includes RFID collections and remains versioned', () {
    expect(BackupEnvelope.currentSchemaVersion, 9);
    expect(IsarBackupStore.collectionNames, contains('rfidBindings'));
    expect(IsarBackupStore.collectionNames, contains('rfidScanSessions'));
    expect(IsarBackupStore.collectionNames, contains('cultivations'));
  });
}
