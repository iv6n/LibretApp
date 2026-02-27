/// Sistema de producción utilizado para el animal.
enum ProductionSystem {
  extensive,
  intensive,
  feedlot,
  mixed,
  organic,
  rotational,
  unknown;

  String get displayName {
    switch (this) {
      case ProductionSystem.extensive:
        return 'Extensivo';
      case ProductionSystem.intensive:
        return 'Intensivo';
      case ProductionSystem.feedlot:
        return 'Corral de Engorde';
      case ProductionSystem.mixed:
        return 'Mixto';
      case ProductionSystem.organic:
        return 'Orgánico';
      case ProductionSystem.rotational:
        return 'Rotacional';
      case ProductionSystem.unknown:
        return 'Desconocido';
    }
  }
}
