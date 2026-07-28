/// features › reportes › data › report_summary — aggregated ranch report snapshot.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';

class SpeciesCount extends Equatable {
  const SpeciesCount({required this.species, required this.count});

  final Species species;
  final int count;

  @override
  List<Object?> get props => [species, count];
}

class CategoryCount extends Equatable {
  const CategoryCount({required this.category, required this.count});

  final Category category;
  final int count;

  @override
  List<Object?> get props => [category, count];
}

enum ReportType {
  sanitary,
  reproductive,
  financial,
  location,
  batch,
  inventory,
  pdfExport,
}

extension ReportTypeLabel on ReportType {
  String get label {
    switch (this) {
      case ReportType.sanitary:
        return 'Reporte sanitario';
      case ReportType.reproductive:
        return 'Reporte reproductivo';
      case ReportType.financial:
        return 'Reporte financiero';
      case ReportType.location:
        return 'Por ubicación';
      case ReportType.batch:
        return 'Por lote';
      case ReportType.inventory:
        return 'Inventario';
      case ReportType.pdfExport:
        return 'Exportar PDF';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.sanitary:
        return Icons.medical_services_outlined;
      case ReportType.reproductive:
        return Icons.pregnant_woman_outlined;
      case ReportType.financial:
        return Icons.account_balance_wallet_outlined;
      case ReportType.location:
        return Icons.location_on_outlined;
      case ReportType.batch:
        return Icons.group_work_outlined;
      case ReportType.inventory:
        return Icons.inventory_2_outlined;
      case ReportType.pdfExport:
        return Icons.picture_as_pdf_outlined;
    }
  }
}

class RecentRecordItem extends Equatable {
  const RecentRecordItem({
    required this.title,
    required this.subtitle,
    required this.date,
    this.animalTag,
    this.route,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final String? animalTag;
  final String? route;

  @override
  List<Object?> get props => [title, subtitle, date, animalTag, route];
}

class ReportSummary extends Equatable {
  const ReportSummary({
    required this.totalAnimals,
    required this.bySpecies,
    required this.byCategory,
    required this.upcomingCalvings,
    required this.healthAlertsCount,
    required this.unvaccinatedCount,
    required this.underObservationCount,
    required this.recentMovements,
    required this.recentRecords,
    required this.generatedAt,
  });

  final int totalAnimals;
  final List<SpeciesCount> bySpecies;
  final List<CategoryCount> byCategory;
  final List<CalvingItem> upcomingCalvings;
  final int healthAlertsCount;
  final int unvaccinatedCount;
  final int underObservationCount;
  final List<RecentRecordItem> recentMovements;
  final List<RecentRecordItem> recentRecords;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [
    totalAnimals,
    bySpecies,
    byCategory,
    upcomingCalvings,
    healthAlertsCount,
    unvaccinatedCount,
    underObservationCount,
    recentMovements,
    recentRecords,
    generatedAt,
  ];
}
