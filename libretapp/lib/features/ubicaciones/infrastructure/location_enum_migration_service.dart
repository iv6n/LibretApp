/// features › ubicaciones › infrastructure › location_enum_migration_service
///
/// One-time migration that rewrites old Spanish enum string values stored in
/// Isar to the new English equivalents introduced in this refactoring cycle.
///
/// Affected fields
/// ───────────────
/// • IsarLocation.type       (LocationType)
/// • IsarLocation.status     (LocationStatus)
/// • IsarInventoryItem.category (InventoryCategory) — inside each location
/// • IsarWaterRecord.type    (WaterType) — inside each location
///
/// Gate: SharedPreferences flag "locationEnumsMigrated_v1".
///       Migration runs once on first launch after the update; subsequent
///       launches skip it entirely.
library;

import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

const _kMigrationFlagKey = 'locationEnumsMigrated_v1';

class LocationEnumMigrationService {
  const LocationEnumMigrationService({
    required Isar isar,
    required SharedPreferences prefs,
  }) : _isar = isar,
       _prefs = prefs;

  final Isar _isar;
  final SharedPreferences _prefs;

  /// Run migration if it has not yet been applied.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> runIfNeeded() async {
    if (_prefs.getBool(_kMigrationFlagKey) == true) return;

    await _migrate();

    await _prefs.setBool(_kMigrationFlagKey, true);
  }

  Future<void> _migrate() async {
    final locations = await _isar.isarLocations.where().findAll();
    if (locations.isEmpty) {
      // Nothing to migrate — still mark as done.
      return;
    }

    final migratedLocations = <IsarLocation>[];

    for (final loc in locations) {
      var changed = false;

      // ── LocationType ────────────────────────────────────────────────────
      final newType =
          LocationTypeX.legacyNameMap[loc.type] ??
          _verifyEnglish(
            loc.type,
            LocationType.values.map((e) => e.name).toSet(),
            fallback: LocationType.ranch.name,
          );
      if (newType != loc.type) {
        loc.type = newType;
        changed = true;
      }

      // ── LocationStatus ───────────────────────────────────────────────────
      final newStatus =
          LocationStatusX.legacyNameMap[loc.status] ??
          _verifyEnglish(
            loc.status,
            LocationStatus.values.map((e) => e.name).toSet(),
            fallback: LocationStatus.available.name,
          );
      if (newStatus != loc.status) {
        loc.status = newStatus;
        changed = true;
      }

      // ── InventoryCategory (inside inventory items) ───────────────────────
      for (final item in loc.inventory) {
        final newCategory =
            InventoryCategoryX.legacyNameMap[item.category] ??
            _verifyEnglish(
              item.category,
              InventoryCategory.values.map((e) => e.name).toSet(),
              fallback: InventoryCategory.other.name,
            );
        if (newCategory != item.category) {
          item.category = newCategory;
          changed = true;
        }
      }

      // ── WaterType (inside water records) ─────────────────────────────────
      for (final water in loc.waters) {
        final newWaterType =
            WaterTypeX.legacyNameMap[water.type] ??
            _verifyEnglish(
              water.type,
              WaterType.values.map((e) => e.name).toSet(),
              fallback: WaterType.well.name,
            );
        if (newWaterType != water.type) {
          water.type = newWaterType;
          changed = true;
        }
      }

      if (changed) migratedLocations.add(loc);
    }

    if (migratedLocations.isEmpty) return;

    await _isar.writeTxn(() async {
      await _isar.isarLocations.putAll(migratedLocations);
    });
  }

  /// Returns [value] unchanged if it is already a valid English enum name;
  /// otherwise returns [fallback].
  String _verifyEnglish(
    String value,
    Set<String> valid, {
    required String fallback,
  }) {
    return valid.contains(value) ? value : fallback;
  }
}
