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
