/// One-time migration from crops embedded in locations to cultivations.
library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/isar_cultivation.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

const cultivationMigrationV1Key = 'cultivations.migration.v1.done';

class CultivationMigrationService {
  const CultivationMigrationService({required this.isar, required this.prefs, this.preferencePrefix = ''});

  final Isar isar;
  final SharedPreferences prefs;
  final String preferencePrefix;

  Future<int> runIfNeeded() async {
    final hasLegacy = await _hasLegacyCrops(isar);
    if ((prefs.getBool('$preferencePrefix$cultivationMigrationV1Key') ?? false) && !hasLegacy) {
      return 0;
    }
    final migrated = await migrateLegacyCultivations(isar);
    if (!await prefs.setBool('$preferencePrefix$cultivationMigrationV1Key', true)) throw StateError('No se pudo guardar la migración.');
    return migrated;
  }

  Future<int> runAfterRestore() => migrateLegacyCultivations(isar);
}

Future<int> migrateLegacyCultivations(Isar isar, {bool inTransaction = false}) async {
  final locations = await isar.isarLocations.where().findAll();
  final legacyCount = locations.fold<int>(
    0,
    (total, location) => total + location.crops.length,
  );
  if (legacyCount == 0) return 0;

  var migrated = 0;
  Future<void> apply() async {
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
  }
  if (inTransaction) { await apply(); } else { await isar.writeTxn(apply); }
  return migrated;
}

Future<bool> _hasLegacyCrops(Isar isar) async {
  final locations = await isar.isarLocations.where().findAll();
  return locations.any((location) => location.crops.isNotEmpty);
}
