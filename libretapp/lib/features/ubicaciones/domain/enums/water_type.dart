/// features \u203a ubicaciones \u203a domain \u203a enums \u203a water_type \u2014 enum for types of water source.
///
/// ALL values are English identifiers.
/// Migration note: old Spanish Isar values were migrated by LocationEnumMigrationService.
library;

enum WaterType { well, dam, tank, spring, river, pond, trough }

extension WaterTypeX on WaterType {
  /// Fallback English label. Production UI should use ARB keys.
  String get label {
    switch (this) {
      case WaterType.well:
        return 'Well';
      case WaterType.dam:
        return 'Dam';
      case WaterType.tank:
        return 'Tank';
      case WaterType.spring:
        return 'Spring';
      case WaterType.river:
        return 'River';
      case WaterType.pond:
        return 'Pond';
      case WaterType.trough:
        return 'Trough';
    }
  }

  /// Mapping from old Spanish Isar-stored enum names to new English names.
  /// Used exclusively by LocationEnumMigrationService.
  static const Map<String, String> legacyNameMap = {
    'pozo': 'well',
    'represo': 'dam',
    'pila': 'tank',
  };
}
