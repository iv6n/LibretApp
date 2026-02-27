/// Etapa de producción del animal dentro de su ciclo de vida productivo.
enum ProductionStage {
  preWeaning,
  postWeaning,
  growth,
  finishing,
  reproductive,
  lactating,
  idle,
  unknown;

  String get displayName {
    switch (this) {
      case ProductionStage.preWeaning:
        return 'Pre-destete';
      case ProductionStage.postWeaning:
        return 'Post-destete';
      case ProductionStage.growth:
        return 'Crecimiento';
      case ProductionStage.finishing:
        return 'Finalización';
      case ProductionStage.reproductive:
        return 'Reproductiva';
      case ProductionStage.lactating:
        return 'Lactación';
      case ProductionStage.idle:
        return 'Inactiva';
      case ProductionStage.unknown:
        return 'Desconocida';
    }
  }
}
