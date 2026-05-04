/// features \u203a ubicaciones \u203a domain \u203a enums \u203a crop_status \u2014 enum for crop lifecycle status.
library;

enum CropStatus { active, harvested, failed }

extension CropStatusX on CropStatus {
  String get displayName {
    switch (this) {
      case CropStatus.active:
        return 'Activo';
      case CropStatus.harvested:
        return 'Cosechado';
      case CropStatus.failed:
        return 'Perdido';
    }
  }
}
