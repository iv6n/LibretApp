/// Native Isar startup migrations.
library;

import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/cultivation_migration_service.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/location_enum_migration_service.dart';

Future<void> runLocationEnumMigrationIfRegistered() async {
  if (locator.isRegistered<LocationEnumMigrationService>()) {
    await locator<LocationEnumMigrationService>().runIfNeeded();
  }
}

Future<int> runCultivationMigrationIfRegistered() async {
  if (!locator.isRegistered<CultivationMigrationService>()) return 0;
  return locator<CultivationMigrationService>().runIfNeeded();
}
