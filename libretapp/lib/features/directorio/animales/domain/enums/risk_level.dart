/// Nivel de riesgo del animal para operaciones ganaderas.
enum RiskLevel {
  none,
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case RiskLevel.none:
        return 'Sin Riesgo';
      case RiskLevel.low:
        return 'Bajo';
      case RiskLevel.medium:
        return 'Medio';
      case RiskLevel.high:
        return 'Alto';
      case RiskLevel.critical:
        return 'Crítico';
    }
  }

  String get hexColor {
    switch (this) {
      case RiskLevel.none:
        return '#00AA00';
      case RiskLevel.low:
        return '#44BB44';
      case RiskLevel.medium:
        return '#FFAA00';
      case RiskLevel.high:
        return '#FF6600';
      case RiskLevel.critical:
        return '#FF0000';
    }
  }
}
