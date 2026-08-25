/// features › ubicaciones › domain › enums › location_status — status of a location.
///
/// ALL values are English identifiers. Display labels live in frontend l10n only.
/// Migration note: old Spanish Isar values were migrated by [LocationEnumMigrationService].
library;

import 'package:flutter/material.dart';

enum LocationStatus {
  available,
  inUse,
  resting,
  closed,
  inPreparation,
  abandoned,
}

extension LocationStatusX on LocationStatus {
  /// Fallback English label. Production UI should use ARB keys.
  String get label {
    switch (this) {
      case LocationStatus.available:
        return 'Available';
      case LocationStatus.inUse:
        return 'In Use';
      case LocationStatus.resting:
        return 'Resting';
      case LocationStatus.closed:
        return 'Closed';
      case LocationStatus.inPreparation:
        return 'In Preparation';
      case LocationStatus.abandoned:
        return 'Abandoned';
    }
  }

  /// Icon and label colour for this status on a surface of [brightness].
  ///
  /// Brightness-aware because the light values are saturated mid-tones chosen
  /// against cream; on the dark surface they sit at 1.3-2.1:1 and are
  /// unreadable. Every value here clears 3:1 against its own surface.
  Color foregroundOn(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    switch (this) {
      case LocationStatus.available:
        return dark ? const Color(0xFF7FC98A) : const Color(0xFF2E7D32);
      case LocationStatus.inUse:
        return dark ? const Color(0xFF79B8F0) : const Color(0xFF1565C0);
      case LocationStatus.resting:
        return dark ? const Color(0xFFF0A868) : const Color(0xFFE65100);
      case LocationStatus.closed:
        return dark ? const Color(0xFFF08A80) : const Color(0xFFC62828);
      case LocationStatus.inPreparation:
        return dark ? const Color(0xFFC89AE0) : const Color(0xFF6A1B9A);
      case LocationStatus.abandoned:
        return dark ? const Color(0xFFA8B4B0) : const Color(0xFF757575);
    }
  }

  /// Chip fill for this status on a surface of [brightness].
  ///
  /// Derived as a wash of [foregroundOn] rather than a fixed pastel: the old
  /// fixed values were light pastels with no dark variant, so a status chip
  /// rendered as a near-white block on the dark surface.
  Color backgroundOn(Brightness brightness) => foregroundOn(
    brightness,
  ).withValues(alpha: brightness == Brightness.dark ? 0.18 : 0.14);

  /// Mapping from old Spanish Isar-stored enum names to new English names.
  /// Used exclusively by [LocationEnumMigrationService].
  static const Map<String, String> legacyNameMap = {
    'disponible': 'available',
    'enUso': 'inUse',
    'enDescanso': 'resting',
    'clausurado': 'closed',
    'enPreparacion': 'inPreparation',
  };
}
