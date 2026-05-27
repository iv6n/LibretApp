/// features \u203a inicio \u203a data \u203a inicio_dashboard_models \u2014 data models for the dashboard.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

class CategorySummary extends Equatable {
  const CategorySummary({
    required this.category,
    required this.total,
    required this.maleCount,
    required this.femaleCount,
  });

  final Category category;
  final int total;
  final int maleCount;
  final int femaleCount;

  @override
  List<Object?> get props => [category, total, maleCount, femaleCount];
}

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

// ---------------------------------------------------------------------------
// WeatherData
// ---------------------------------------------------------------------------

class WeatherData extends Equatable {
  const WeatherData({
    required this.temperature,
    required this.maxTemperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  final int temperature;
  final int maxTemperature;
  final String condition;
  final int humidity;
  final int windSpeed;

  @override
  List<Object?> get props => [
    temperature,
    maxTemperature,
    condition,
    humidity,
    windSpeed,
  ];
}

// ---------------------------------------------------------------------------
// RecentActivityItem
// ---------------------------------------------------------------------------

class RecentActivityItem extends Equatable {
  const RecentActivityItem({
    required this.animalUuid,
    required this.animalTag,
    this.animalName,
    required this.categoryLabel,
    required this.categoryAbbrev,
    required this.lastUpdate,
    this.photoPath,
  });

  final String animalUuid;
  final String animalTag;
  final String? animalName;
  final String categoryLabel;
  final String categoryAbbrev;
  final DateTime lastUpdate;
  final String? photoPath;

  @override
  List<Object?> get props => [animalUuid, lastUpdate, photoPath];
}

// ---------------------------------------------------------------------------
// CalvingItem
// ---------------------------------------------------------------------------

class CalvingItem extends Equatable {
  const CalvingItem({
    required this.animalUuid,
    required this.animalTag,
    this.animalName,
    required this.expectedDate,
    required this.daysRemaining,
  });

  final String animalUuid;
  final String animalTag;
  final String? animalName;
  final DateTime expectedDate;
  final int daysRemaining;

  @override
  List<Object?> get props => [animalUuid, expectedDate];
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
    required this.categoryBreakdown,
    required this.upcomingCalvings,
    this.weather,
    this.recentActivity = const [],
  });

  final String profileName;
  final String farmName;
  final int totalAnimals;
  final int attentionAnimals;
  final int unsyncedAnimals;
  final int activeLotes;
  final int totalLocations;
  final int upcomingEventsCount;
  final List<AgendaEntry> upcomingEvents;
  final List<InicioAlertItem> alerts;
  final List<InicioTaskItem> tasks;
  final DateTime lastUpdated;
  final List<CategorySummary> categoryBreakdown;
  final List<CalvingItem> upcomingCalvings;
  final WeatherData? weather;
  final List<RecentActivityItem> recentActivity;

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
    categoryBreakdown,
    upcomingCalvings,
    weather,
    recentActivity,
  ];
}
