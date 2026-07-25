/// features › inicio › data › dashboard_widget_config — dashboard widget layout model.
library;

import 'package:equatable/equatable.dart';

enum DashboardWidgetType {
  animalSummary,
  upcomingEvents,
  healthAlerts,
  upcomingCalvings,
  financeMonth,
  activeLocations,
  recentActivity,
  pendingTasks,
  weather,
  inventory,
  libraryPicks,
}

enum DashboardWidgetSize { compact, expanded }

extension DashboardWidgetTypeLabel on DashboardWidgetType {
  String get label {
    switch (this) {
      case DashboardWidgetType.animalSummary:
        return 'Resumen de animales';
      case DashboardWidgetType.upcomingEvents:
        return 'Próximos eventos';
      case DashboardWidgetType.healthAlerts:
        return 'Alertas sanitarias';
      case DashboardWidgetType.upcomingCalvings:
        return 'Próximos partos';
      case DashboardWidgetType.financeMonth:
        return 'Finanzas del mes';
      case DashboardWidgetType.activeLocations:
        return 'Ubicaciones activas';
      case DashboardWidgetType.recentActivity:
        return 'Registros recientes';
      case DashboardWidgetType.pendingTasks:
        return 'Tareas pendientes';
      case DashboardWidgetType.weather:
        return 'Clima';
      case DashboardWidgetType.inventory:
        return 'Inventario';
      case DashboardWidgetType.libraryPicks:
        return 'Biblioteca recomendada';
    }
  }
}

class DashboardWidgetConfig extends Equatable {
  const DashboardWidgetConfig({
    required this.id,
    required this.title,
    required this.type,
    required this.enabled,
    required this.order,
    this.size = DashboardWidgetSize.compact,
    this.settings,
  });

  final String id;
  final String title;
  final DashboardWidgetType type;
  final bool enabled;
  final int order;
  final DashboardWidgetSize size;
  final Map<String, dynamic>? settings;

  DashboardWidgetConfig copyWith({
    String? id,
    String? title,
    DashboardWidgetType? type,
    bool? enabled,
    int? order,
    DashboardWidgetSize? size,
    Map<String, dynamic>? settings,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      size: size ?? this.size,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'enabled': enabled,
    'order': order,
    'size': size.name,
    if (settings != null) 'settings': settings,
  };

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: DashboardWidgetType.values.byName(
        json['type'] as String? ?? DashboardWidgetType.animalSummary.name,
      ),
      enabled: json['enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      size: DashboardWidgetSize.values.byName(
        json['size'] as String? ?? DashboardWidgetSize.compact.name,
      ),
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, title, type, enabled, order, size, settings];
}

/// Default widget layout for new users.
List<DashboardWidgetConfig> defaultDashboardWidgets() {
  const types = [
    DashboardWidgetType.healthAlerts,
    DashboardWidgetType.upcomingCalvings,
    DashboardWidgetType.upcomingEvents,
    DashboardWidgetType.financeMonth,
    DashboardWidgetType.activeLocations,
    DashboardWidgetType.recentActivity,
    DashboardWidgetType.pendingTasks,
    DashboardWidgetType.weather,
    DashboardWidgetType.inventory,
    DashboardWidgetType.libraryPicks,
  ];
  return List.generate(
    types.length,
    (i) => DashboardWidgetConfig(
      id: types[i].name,
      title: types[i].label,
      type: types[i],
      enabled: types[i] != DashboardWidgetType.inventory &&
          types[i] != DashboardWidgetType.animalSummary &&
          types[i] != DashboardWidgetType.weather,
      order: i,
      size: types[i] == DashboardWidgetType.financeMonth
          ? DashboardWidgetSize.expanded
          : DashboardWidgetSize.compact,
    ),
  );
}
