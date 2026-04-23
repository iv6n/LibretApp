import 'package:equatable/equatable.dart';

/// Categoría temática del consejo ganadero.
enum TipCategory {
  movement,
  health,
  reproduction,
  nutrition,
  production;

  String get displayName {
    switch (this) {
      case TipCategory.movement:
        return 'Movimiento';
      case TipCategory.health:
        return 'Salud';
      case TipCategory.reproduction:
        return 'Reproducción';
      case TipCategory.nutrition:
        return 'Nutrición';
      case TipCategory.production:
        return 'Producción';
    }
  }

  String get icon {
    switch (this) {
      case TipCategory.movement:
        return '🚜';
      case TipCategory.health:
        return '🩺';
      case TipCategory.reproduction:
        return '🐄';
      case TipCategory.nutrition:
        return '🌾';
      case TipCategory.production:
        return '📊';
    }
  }
}

/// Severidad del consejo — determina prominencia visual.
enum TipSeverity {
  info,
  warning,
  critical;

  String get displayName {
    switch (this) {
      case TipSeverity.info:
        return 'Información';
      case TipSeverity.warning:
        return 'Advertencia';
      case TipSeverity.critical:
        return 'Crítico';
    }
  }
}

/// Un consejo contextual de la "Biblia Ganadera".
///
/// Se genera automáticamente al evaluar reglas contra el estado actual
/// de un animal y la acción que el usuario está realizando.
class LivestockTip extends Equatable {
  const LivestockTip({
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    this.source,
  });

  /// Categoría temática (movimiento, salud, etc.).
  final TipCategory category;

  /// Severidad del consejo.
  final TipSeverity severity;

  /// Título corto (ej: "Cambio de dieta gradual").
  final String title;

  /// Descripción completa de la recomendación.
  final String description;

  /// Fuente bibliográfica o referencia (opcional).
  final String? source;

  @override
  List<Object?> get props => [category, severity, title, description, source];
}
