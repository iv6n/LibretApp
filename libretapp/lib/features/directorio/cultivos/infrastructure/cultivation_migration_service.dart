/// One-time migration from crops embedded in locations to cultivations.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/isar_cultivation.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

const cultivationMigrationV1Key = 'cultivations.migration.v1.done';

class CultivationMigrationService {
  const CultivationMigrationService({required this.isar, required this.prefs});

  final Isar isar;
  final SharedPreferences prefs;

  Future<int> runIfNeeded() async {
    final hasLegacy = await _hasLegacyCrops(isar);
    if ((prefs.getBool(cultivationMigrationV1Key) ?? false) && !hasLegacy) {
      return 0;
    }
    final migrated = await migrateLegacyCultivations(isar);
    await prefs.setBool(cultivationMigrationV1Key, true);
    return migrated;
  }

  Future<int> runAfterRestore() => migrateLegacyCultivations(isar);
}

Future<int> migrateLegacyCultivations(Isar isar) async {
  final locations = await isar.isarLocations.where().findAll();
  final legacyCount = locations.fold<int>(
    0,
    (total, location) => total + location.crops.length,
  );
  if (legacyCount == 0) return 0;

  var migrated = 0;
  await isar.writeTxn(() async {
    for (final location in locations) {
      if (location.crops.isEmpty) continue;
      for (final crop in location.crops) {
        final existing = await isar.isarCultivations
            .filter()
            .uuidEqualTo(crop.uuid)
            .findFirst();
        if (existing != null) continue;
        final entity = CultivationEntity.fromLegacyCrop(
          crop: crop.toEntity(),
          locationUuid: location.uuid,
          createdAt: crop.plantingDate,
          updatedAt: location.updatedAt,
        );
        await isar.isarCultivations.put(IsarCultivation.fromEntity(entity));
        migrated++;
      }
      location.crops = [];
      await isar.isarLocations.put(location);
    }
  });
  return migrated;
}

Future<bool> _hasLegacyCrops(Isar isar) async {
  final locations = await isar.isarLocations.where().findAll();
  return locations.any((location) => location.crops.isNotEmpty);
}
