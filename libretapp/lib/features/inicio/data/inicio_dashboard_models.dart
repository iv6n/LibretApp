import 'package:equatable/equatable.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';

enum InicioAlertSeverity { critical, warning, info }

class InicioAlertItem extends Equatable {
  const InicioAlertItem({
    required this.title,
    required this.message,
    required this.severity,
    required this.targetRoute,
  });

  final String title;
  final String message;
  final InicioAlertSeverity severity;
  final String targetRoute;

  @override
  List<Object?> get props => [title, message, severity, targetRoute];
}

class InicioTaskItem extends Equatable {
  const InicioTaskItem({
    required this.title,
    required this.message,
    required this.targetRoute,
  });

  final String title;
  final String message;
  final String targetRoute;

  @override
  List<Object?> get props => [title, message, targetRoute];
}

class InicioDashboardData extends Equatable {
  const InicioDashboardData({
    required this.profileName,
    required this.farmName,
    required this.totalAnimals,
    required this.attentionAnimals,
    required this.unsyncedAnimals,
    required this.activeLotes,
    required this.totalLocations,
    required this.upcomingEventsCount,
    required this.upcomingEvents,
    required this.alerts,
    required this.tasks,
    required this.lastUpdated,
  });

  final String profileName;
  final String farmName;
  final int totalAnimals;
  final int attentionAnimals;
  final int unsyncedAnimals;
  final int activeLotes;
  final int totalLocations;
  final int upcomingEventsCount;
  final List<Evento> upcomingEvents;
  final List<InicioAlertItem> alerts;
  final List<InicioTaskItem> tasks;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [
    profileName,
    farmName,
    totalAnimals,
    attentionAnimals,
    unsyncedAnimals,
    activeLotes,
    totalLocations,
    upcomingEventsCount,
    upcomingEvents,
    alerts,
    tasks,
    lastUpdated,
  ];
}
