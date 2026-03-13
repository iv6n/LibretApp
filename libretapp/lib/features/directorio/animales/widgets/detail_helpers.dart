import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';

/// Aggregated data for the animal detail screen.
class DetailData {
  DetailData({
    required this.animal,
    required this.weights,
    required this.reproductions,
    required this.productions,
    required this.health,
    required this.commercial,
    required this.movements,
    required this.costs,
  });

  final AnimalEntity animal;
  final List<WeightRecord> weights;
  final List<ReproductionRecord> reproductions;
  final List<ProductionRecord> productions;
  final List<HealthRecord> health;
  final List<CommercialRecord> commercial;
  final List<MovementRecord> movements;
  final List<CostRecord> costs;
}

Color detailStageColor(LifeStage stage) {
  return AnimalPalette.stageColor(stage);
}

String stageAsset(LifeStage stage) {
  switch (stage) {
    case LifeStage.calf:
    case LifeStage.calfMale:
    case LifeStage.calfFemale:
      return 'assets/images/becerro.png';
    case LifeStage.heifer:
      return 'assets/images/vaquilla.png';
    case LifeStage.youngBull:
      return 'assets/images/toro.png';
    case LifeStage.steer:
      return 'assets/images/novillo.png';
    case LifeStage.cow:
      return 'assets/images/vaca.png';
    case LifeStage.bull:
      return 'assets/images/toro.png';
    case LifeStage.colt:
    case LifeStage.filly:
      return 'assets/images/caballo.png';
    case LifeStage.horse:
    case LifeStage.mare:
      return 'assets/images/caballo.png';
    case LifeStage.donkey:
    case LifeStage.donkeyFemale:
      return 'assets/images/burro.png';
    case LifeStage.mule:
      return 'assets/images/mula.png';
  }
}

String formatDate(DateTime? date, {bool withTime = false}) {
  if (date == null) return 'Sin dato';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final base = '$day/$month/$year';
  if (!withTime) return base;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$base $hour:$minute';
}

String fmtDate(DateTime date) => formatDate(date);

String formatAge(int months) {
  if (months < 12) {
    return '$months mes${months == 1 ? '' : 'es'}';
  }
  final years = months ~/ 12;
  final remaining = months % 12;
  if (remaining == 0) {
    return '$years año${years == 1 ? '' : 's'}';
  }
  return '$years año${years == 1 ? '' : 's'} $remaining mes${remaining == 1 ? '' : 'es'}';
}

Color detailColorFromHex(String hex) {
  final sanitized = hex.replaceFirst('#', '');
  final buffer = StringBuffer();
  if (sanitized.length == 6) {
    buffer.write('ff');
  }
  buffer.write(sanitized);
  return Color(int.parse(buffer.toString(), radix: 16));
}

List<String> uniqueBatches(List<AnimalEntity> animals) {
  final batches = animals
      .map((a) => a.batchId?.trim())
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();
  batches.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return batches;
}
