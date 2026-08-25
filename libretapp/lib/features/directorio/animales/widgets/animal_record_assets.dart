/// Asset mapping for the health and production records shown in the animal
/// detail ficha.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

String? assetForHealthRecordType(HealthRecordType type) => switch (type) {
  HealthRecordType.vaccine => AppAssetPaths.healthVaccine,
  HealthRecordType.treatment => AppAssetPaths.healthTreatment,
  HealthRecordType.disease ||
  HealthRecordType.checkup => AppAssetPaths.healthDiagnosis,
  _ => null,
};

IconData fallbackIconForHealthRecordType(HealthRecordType type) =>
    switch (type) {
      HealthRecordType.vaccine => Icons.vaccines_outlined,
      HealthRecordType.treatment => Icons.medication_outlined,
      HealthRecordType.disease => Icons.sick_outlined,
      HealthRecordType.checkup => Icons.medical_services_outlined,
      HealthRecordType.deworming => Icons.bug_report_outlined,
      HealthRecordType.tickBath => Icons.water_drop_outlined,
      HealthRecordType.vitamins => Icons.medication_outlined,
      HealthRecordType.death => Icons.warning_amber_outlined,
      HealthRecordType.other => Icons.health_and_safety_outlined,
    };

String? assetForProductionRecordType(ProductionRecordType type) =>
    switch (type) {
      ProductionRecordType.weighing ||
      ProductionRecordType.weightGain => AppAssetPaths.healthWeight,
      ProductionRecordType.production => AppAssetPaths.healthMilkProduction,
      ProductionRecordType.bodyConditionScore =>
        AppAssetPaths.healthBodyCondition,
      ProductionRecordType.fatteningStart ||
      ProductionRecordType.fatteningEnd => null,
    };

IconData fallbackIconForProductionRecordType(ProductionRecordType type) =>
    switch (type) {
      ProductionRecordType.weighing ||
      ProductionRecordType.weightGain => Icons.monitor_weight_outlined,
      ProductionRecordType.bodyConditionScore => Icons.analytics_outlined,
      ProductionRecordType.production => Icons.water_drop_outlined,
      ProductionRecordType.fatteningStart ||
      ProductionRecordType.fatteningEnd => Icons.agriculture_outlined,
    };
