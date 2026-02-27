/// Estado de salud actual del animal.
enum HealthStatus {
  excellent,
  good,
  fair,
  poor,
  critical,
  unknown;

  String get displayName {
    switch (this) {
      case HealthStatus.excellent:
        return 'Excelente';
      case HealthStatus.good:
        return 'Bueno';
      case HealthStatus.fair:
        return 'Aceptable';
      case HealthStatus.poor:
        return 'Comprometido';
      case HealthStatus.critical:
        return 'Crítico';
      case HealthStatus.unknown:
        return 'Desconocido';
    }
  }

  String get hexColor {
    switch (this) {
      case HealthStatus.excellent:
        return '#00AA00';
      case HealthStatus.good:
        return '#44BB44';
      case HealthStatus.fair:
        return '#FFAA00';
      case HealthStatus.poor:
        return '#FF6600';
      case HealthStatus.critical:
        return '#FF0000';
      case HealthStatus.unknown:
        return '#AAAAAA';
    }
  }
}
