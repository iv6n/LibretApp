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

  Color get color {
    switch (this) {
      case LocationStatus.available:
        return const Color(0xFF2E7D32); // green
      case LocationStatus.inUse:
        return const Color(0xFF1565C0); // blue
      case LocationStatus.resting:
        return const Color(0xFFE65100); // orange
      case LocationStatus.closed:
        return const Color(0xFFC62828); // red
      case LocationStatus.inPreparation:
        return const Color(0xFF6A1B9A); // purple
      case LocationStatus.abandoned:
        return const Color(0xFF757575); // grey
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LocationStatus.available:
        return const Color(0xFFE8F5E9);
      case LocationStatus.inUse:
        return const Color(0xFFE3F2FD);
      case LocationStatus.resting:
        return const Color(0xFFFFF3E0);
      case LocationStatus.closed:
        return const Color(0xFFFFEBEE);
      case LocationStatus.inPreparation:
        return const Color(0xFFF3E5F5);
      case LocationStatus.abandoned:
        return const Color(0xFFF5F5F5);
    }
  }

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
