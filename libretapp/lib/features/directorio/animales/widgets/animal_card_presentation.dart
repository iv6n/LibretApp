/// Presentation rules shared by animal cards and compact directory rows.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

import 'animal_palette.dart';

bool animalRiskStatusHasPriority(HealthStatus health, RiskLevel risk) {
  final healthPriority = switch (health) {
    HealthStatus.excellent || HealthStatus.good || HealthStatus.unknown => 0,
    HealthStatus.fair => 2,
    HealthStatus.poor => 3,
    HealthStatus.critical => 4,
  };
  final riskPriority = switch (risk) {
    RiskLevel.none => 0,
    RiskLevel.low => 1,
    RiskLevel.medium => 2,
    RiskLevel.high => 3,
    RiskLevel.critical => 4,
  };
  return riskPriority > healthPriority;
}

bool isNeutralAnimalHealthStatus(HealthStatus status) => switch (status) {
  HealthStatus.good || HealthStatus.excellent || HealthStatus.unknown => true,
  HealthStatus.fair || HealthStatus.poor || HealthStatus.critical => false,
};

bool isNeutralAnimalRiskLevel(RiskLevel level) => switch (level) {
  RiskLevel.none || RiskLevel.low => true,
  RiskLevel.medium || RiskLevel.high || RiskLevel.critical => false,
};

Color animalColorFromHex(String hex) {
  final digits = hex.replaceFirst('#', '');
  return Color(int.parse(digits.length == 6 ? 'ff$digits' : digits, radix: 16));
}

Color animalIndicatorAccentColor(
  BuildContext context,
  PurposeIndicator indicator,
) => switch (indicator.severity) {
  IndicatorSeverity.critical => const Color(0xFFD93A2F),
  IndicatorSeverity.attention => const Color(0xFFC58B2A),
  IndicatorSeverity.neutral => AnimalPalette.summaryChipAccent(context),
};

Color animalIndicatorTextColor(
  BuildContext context,
  PurposeIndicator indicator,
  ProductionPurpose purpose,
) => switch (indicator.severity) {
  IndicatorSeverity.critical => const Color(0xFF7A1B14),
  IndicatorSeverity.attention => const Color(0xFF704A00),
  IndicatorSeverity.neutral => AnimalPalette.purposeSummaryTextColor(purpose),
};

({Color background, Color foreground, Color border}) animalStatusPillColors({
  required bool isDark,
  required Color? accentColor,
}) {
  if (accentColor == null) {
    final foreground = isDark
        ? const Color(0xFFB8C0CA)
        : const Color(0xFF5A6575);
    return (
      background: isDark ? const Color(0xFF3A424D) : const Color(0xFFE8ECF0),
      foreground: foreground,
      border: foreground.withValues(alpha: isDark ? 0.28 : 0.24),
    );
  }
  final toned = Color.lerp(
    accentColor,
    const Color(0xFF9AA7B5),
    isDark ? 0.18 : 0.28,
  )!;
  return (
    background: toned.withValues(alpha: isDark ? 0.24 : 0.16),
    foreground: Color.lerp(
      toned,
      isDark ? Colors.white : const Color(0xFF1E2836),
      isDark ? 0.28 : 0.42,
    )!,
    border: toned.withValues(alpha: isDark ? 0.42 : 0.38),
  );
}

class CompactAnimalAlert {
  const CompactAnimalAlert({
    required this.label,
    required this.severity,
    required this.accentColor,
    required this.icon,
  });

  final String label;
  final IndicatorSeverity severity;
  final Color accentColor;
  final IconData icon;
}

/// Picks one actionable warning. Health/risk wins ties with production,
/// while a critical production warning still outranks an attention status.
CompactAnimalAlert? compactAnimalAlert(
  AnimalEntity animal, {
  AnimalIndicatorSnapshot? snapshot,
}) {
  final showRisk = animalRiskStatusHasPriority(
    animal.healthStatus,
    animal.riskLevel,
  );
  CompactAnimalAlert? result;
  if (showRisk && !isNeutralAnimalRiskLevel(animal.riskLevel)) {
    result = CompactAnimalAlert(
      label: 'Riesgo ${animal.riskLevel.displayName.toLowerCase()}',
      severity: animal.riskLevel == RiskLevel.critical
          ? IndicatorSeverity.critical
          : IndicatorSeverity.attention,
      accentColor: animalColorFromHex(animal.riskLevel.hexColor),
      icon: Icons.warning_amber_rounded,
    );
  } else if (!showRisk && !isNeutralAnimalHealthStatus(animal.healthStatus)) {
    result = CompactAnimalAlert(
      label: animal.healthStatus.displayName,
      severity: animal.healthStatus == HealthStatus.critical
          ? IndicatorSeverity.critical
          : IndicatorSeverity.attention,
      accentColor: animalColorFromHex(animal.healthStatus.hexColor),
      icon: Icons.health_and_safety_outlined,
    );
  }
  for (final indicator in indicatorsFor(animal, snapshot: snapshot)) {
    if (indicator.severity == IndicatorSeverity.neutral ||
        (result != null && indicator.severity.index <= result.severity.index)) {
      continue;
    }
    result = CompactAnimalAlert(
      label: indicator.label,
      severity: indicator.severity,
      accentColor: indicator.severity == IndicatorSeverity.critical
          ? const Color(0xFFD93A2F)
          : const Color(0xFFC58B2A),
      icon: Icons.warning_amber_rounded,
    );
  }
  return result;
}
